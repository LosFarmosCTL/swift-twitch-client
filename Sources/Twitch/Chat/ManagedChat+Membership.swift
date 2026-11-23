import Foundation

extension ManagedChat {
  func requestJoin(to channel: ChatChannel) throws {
    _ = try requestMembership(channel, intent: intentTracker.nextIntent())
  }

  nonisolated(nonsending) func requestJoin(_ reference: ChatChannelReference) async throws {
    _ = try await requestMembership(reference)
  }

  nonisolated(nonsending) func join(to channel: ChatChannel) async throws {
    let member = try requestMembership(channel, intent: intentTracker.nextIntent())
    try await member.waitUntilReady()
  }

  nonisolated(nonsending) func join(_ reference: ChatChannelReference) async throws {
    let member = try await requestMembership(reference)
    try await member.waitUntilReady()
  }

  func part(channelID: String, login: String? = nil) {
    let logins = Set(
      [
        login.map(IRCWireMessage.channelLogin),
        memberships[channelID]?.channel.login,
        knownChannels.channel(id: channelID)?.login,
      ].compactMap { $0 })
    partChannel(channelID, logins: Array(logins), intent: intentTracker.nextIntent())
  }

  nonisolated(nonsending) func part(_ reference: ChatChannelReference) async throws {
    let intent = intentTracker.nextIntent()
    withdrawPendingJoins(for: [reference], before: intent)

    let channel = try await resolveChatChannel(reference)
    partChannel(channel.id, logins: [channel.login], intent: intent)
  }

  func activeMembership(forLogin rawLogin: String) -> Membership? {
    let login = IRCWireMessage.channelLogin(rawLogin)
    return memberships.values.first { $0.channel.login == login }
  }

  func activeMembership(for reference: ChatChannelReference) -> Membership? {
    switch reference {
    case .id(let id): memberships[id]
    case .login(let login): activeMembership(forLogin: login)
    }
  }

  private func requestMembership(_ channel: ChatChannel, intent: UInt64) throws -> Membership {
    try Task.checkCancellation()
    guard !isShutdown else { throw ChatError.shutdown }
    guard channel.isValidForManagedChat else { throw ChatError.invalidChannel }

    let existing = memberships[channel.id]
    let joinIntent = max(existing?.joinIntent ?? 0, intent)

    if let existing {
      guard case .failed = existing.status else {
        guard existing.channel.login == channel.login else {
          throw ChatError.setupFailed("Part #\(existing.channel.login) before changing its login.")
        }
        existing.joinIntent = joinIntent
        return existing
      }
    }

    if case .irc = configuration.reader,
      memberships.values.contains(where: { $0.channel.login == channel.login && $0 !== existing })
    {
      throw ChatError.setupFailed("Part #\(channel.login) before changing its channel ID.")
    }

    existing?.stop()
    cacheChatChannel(channel)

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

  @discardableResult
  func endMembership(_ id: String, reason: ChatDeparture.Reason) -> Bool {
    guard let member = memberships.removeValue(forKey: id) else { return false }

    member.endReadiness(throwing: reason.readinessError)
    member.stop()

    lastDeparture = ChatDeparture(channel: member.channel, reason: reason)
    emitChat(ChatEvent(channel: member.channel, timestamp: nil, payload: .membershipEnded(reason)))
    return true
  }

  // MARK: - Joining and parting through unresolved aliases

  nonisolated(nonsending) private func requestMembership(_ reference: ChatChannelReference)
    async throws -> Membership
  {
    let (intent, waiterID) = intentTracker.beginPendingJoin(reference: reference)
    defer { intentTracker.endPendingJoin(intent: intent) }

    let channel = try await resolveChatChannel(reference, waiterID: waiterID)
    guard !intentTracker.isJoinWithdrawn(channel: channel, reference: reference, intent: intent)
    else { throw ChatError.parted }

    return try requestMembership(channel, intent: intent)
  }

  private func partChannel(_ id: String, logins: [String], intent: UInt64) {
    let references: [ChatChannelReference] = [.id(id)] + logins.map { .login($0) }
    withdrawPendingJoins(for: references, before: intent)

    // A part that needed a lookup cannot undo a newer join.
    guard (memberships[id]?.joinIntent ?? 0) <= intent else { return }

    guard endMembership(id, reason: .requested) else { return }
    updateIRCReaderMembership()
    publishChatState()
  }

  private func withdrawPendingJoins(for references: [ChatChannelReference], before intent: UInt64) {
    for (reference, waiterID) in intentTracker.recordPart(for: references, intent: intent) {
      cancelLookupWaiter(waiterID, for: reference, error: ChatError.parted)
    }
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
