import Foundation

extension ManagedChat {
  func startChatEventSub(_ member: Membership) {
    guard member.eventSub == nil else { return }

    let id = member.channel.id
    guard let userID = credentials?.userID else {
      member.updateStatus(.unavailable("A user access token is required."))
      return
    }

    let attempt = attempt(for: member)
    let topics: [ChatEventSubTopics.Topic] = [
      .init(.channelChatMessage(broadcasterID: id, userID: userID)),
      .init(.channelChatNotification(broadcasterID: id, userID: userID)),
      .init(.channelChatMessageDelete(broadcasterID: id, userID: userID)),
      .init(.channelChatClear(broadcasterID: id, userID: userID)),
      .init(.channelChatClearUserMessages(broadcasterID: id, userID: userID)),
      .init(.channelChatSettingsUpdate(broadcasterID: id, userID: userID)),
    ]

    member.eventSub = observeChatTopics(topics) { chat, update in
      chat.acceptRequiredTopic(update, for: attempt)
    }
  }

  func observeChatTopics(
    _ topics: [ChatEventSubTopics.Topic],
    receive: @escaping @Sendable (ManagedChat, ChatEventSubTopics.Update) -> Void
  ) -> Task<Void, Never> {
    let revision = credentialRevision
    return Task { [weak client] in
      guard let registration = await client?.chatEventSubRegistration(at: revision) else { return }

      await registration.reset?.value
      await ChatEventSubTopics.run(
        topics, client: registration.client, revision: registration.revision
      ) { [weak client] update in
        await client?.withChat { receive($0, update) }
      }
    }
  }

  private func acceptRequiredTopic(
    _ update: ChatEventSubTopics.Update, for attempt: MembershipAttempt
  ) {
    guard isCurrent(attempt), let member = memberships[attempt.channelID] else { return }

    switch update {
    case .ready:
      member.updateStatus(.ready)
      publishChatState()
      startChatSettingsSnapshot(for: attempt)
    case .event(let notification):
      receiveChatEventSub(
        notification.event, timestamp: notification.sentAt, channel: attempt.channel)
    case .ended(let error):
      endRequiredChatTopic(member.channel.id, error: error)
    case .setupFailed(let error):
      member.eventSub = nil
      member.updateStatus(.failed(String(describing: error)), error: error)
      publishChatState()
    }
  }

  private func endRequiredChatTopic(_ id: String, error: EventSubError?) {
    let message = error.map { String(describing: $0) } ?? "EventSub reset"
    let reason: ChatDeparture.Reason

    if case .revocation(let revocation) = error {
      reason = .subscriptionRevoked(revocation.status)
    } else {
      reason = .requiredSubscriptionEnded(message)
    }

    endMembership(id, reason: reason)
    publishChatState()
  }

  var eventSubReaderStatus: ChatComponentStatus {
    let statuses = memberships.values.map(\.status)

    for status in [ChatComponentStatus.ready, .connecting, .reconnecting]
    where statuses.contains(status) {
      return status
    }
    return statuses.first ?? .idle
  }
}

extension TwitchClient {
  func chatEventSubRegistration(at credentialRevision: UInt64)
    -> (client: EventSubClient, revision: UInt64, reset: Task<Void, Never>?)?
  {
    guard chat.credentialRevision == credentialRevision, !chat.isShutdown else { return nil }
    return (eventSubClient, eventSubRevision, eventSubResetTask)
  }
}
