import Foundation

extension ManagedChat {
  func requestJoin(to channel: ChatChannel) throws {
    _ = try requestMembership(channel, intent: nextMembershipIntent())
  }

  nonisolated(nonsending) func requestJoin(_ reference: ChatChannelReference) async throws {
    _ = try await requestMembership(reference)
  }

  nonisolated(nonsending) func join(to channel: ChatChannel) async throws {
    let member = try requestMembership(channel, intent: nextMembershipIntent())
    try await member.waitUntilReady()
  }

  nonisolated(nonsending) func join(_ reference: ChatChannelReference) async throws {
    let member = try await requestMembership(reference)
    try await member.waitUntilReady()
  }

  func part(channelID: String, login: String? = nil) {
    partChannel(
      channelID, login: login ?? knownChannels[.id(channelID)]?.login,
      intent: nextMembershipIntent())
  }

  nonisolated(nonsending) func part(_ reference: ChatChannelReference) async throws {
    let intent = nextMembershipIntent()
    withdrawPendingJoins(for: [reference], before: intent)

    let channel = try await resolveChatChannel(reference)
    partChannel(channel.id, login: channel.login, intent: intent)
  }

  private func requestMembership(_ channel: ChatChannel, intent: UInt64) throws -> Membership {
    try Task.checkCancellation()
    guard !isShutdown else { throw ChatError.shutdown }
    guard channel.isValidForManagedChat else { throw ChatError.invalidChannel }

    cacheChatChannel(channel)
    let existing = memberships[channel.id]
    let joinIntent = max(existing?.joinIntent ?? 0, intent)

    if let existing {
      guard case .failed = existing.status else {
        existing.joinIntent = joinIntent
        return existing
      }
      prepareToRetry(existing)
    }

    let member = Membership(channel: channel, joinIntent: joinIntent)
    memberships[channel.id] = member

    startMembership(member)
    startModerationPrefillIfNeeded()
    publishChatState()
    return member
  }

  func startMembership(_ member: Membership) {
    switch configuration.reader {
    case .irc(let authentication):
      startIRCReaderIfNeeded(authentication: authentication)
      updateIRCReaderMembership()
    case .eventSub:
      startChatEventSub(member)
    }

    reconcileChatModeration(member.channel.id)
  }

  private func prepareToRetry(_ member: Membership) {
    member.stop()
    guard case .irc = configuration.reader else { return }

    readerRetryLogins.insert(member.channel.login)
  }

  func endMembership(_ id: String, reason: ChatDeparture.Reason) {
    guard let member = memberships.removeValue(forKey: id) else { return }

    member.endReadiness(throwing: reason.readinessError)
    member.stop()

    lastDeparture = ChatDeparture(channel: member.channel, reason: reason)
    emitChat(ChatEvent(channel: member.channel, timestamp: nil, payload: .membershipEnded(reason)))
  }

  // MARK: - Joining and parting through unresolved aliases

  struct PendingJoin {
    let reference: ChatChannelReference
    let lookupWaiter = UUID()
  }

  nonisolated(nonsending) private func requestMembership(_ reference: ChatChannelReference)
    async throws -> Membership
  {
    let intent = nextMembershipIntent()
    let pending = PendingJoin(reference: reference)
    pendingJoins[intent] = pending
    defer {
      pendingJoins[intent] = nil
      prunePartIntents()
    }

    let channel = try await resolveChatChannel(reference, waiterID: pending.lookupWaiter)
    // A part by ID can arrive while the same channel is still being resolved by login.
    guard latestPartIntents[.id(channel.id), default: 0] <= intent,
      latestPartIntents[reference, default: 0] <= intent
    else { throw ChatError.parted }

    return try requestMembership(channel, intent: intent)
  }

  private func partChannel(_ id: String, login: String?, intent: UInt64) {
    var references: [ChatChannelReference] = [.id(id)]
    if let login { references.append(.login(login)) }
    withdrawPendingJoins(for: references, before: intent)

    // A part that needed a lookup cannot undo a newer join.
    guard (memberships[id]?.joinIntent ?? 0) <= intent else { return }

    endMembership(id, reason: .requested)
    updateIRCReaderMembership()
    publishChatState()
  }

  private func nextMembershipIntent() -> UInt64 {
    membershipIntent &+= 1
    return membershipIntent
  }

  private func withdrawPendingJoins(for references: [ChatChannelReference], before intent: UInt64) {
    for reference in references {
      latestPartIntents[reference] = max(latestPartIntents[reference, default: 0], intent)
    }
    for (order, pending) in pendingJoins
    where order < intent && references.contains(pending.reference) {
      cancelLookupWaiter(pending.lookupWaiter, for: pending.reference, error: ChatError.parted)
    }
    prunePartIntents()
  }

  private func prunePartIntents() {
    let earliestJoin = pendingJoins.keys.min() ?? membershipIntent
    latestPartIntents = latestPartIntents.filter { $0.value > earliestJoin }
  }
}

extension ChatDeparture.Reason {
  fileprivate var readinessError: ChatError {
    switch self {
    case .requested: .parted
    case .credentialsChanged: .credentialsChanged
    case .subscriptionRevoked, .requiredSubscriptionEnded:
      .setupFailed("Required chat subscription ended")
    case .shutdown: .shutdown
    }
  }
}
