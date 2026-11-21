import Foundation

extension ManagedChat {
  func reconcileChatModeration(_ id: String) {
    guard configuration.moderationEnrichment, let member = memberships[id] else { return }

    let privilege = effectiveChatPrivilege(id)
    guard privilege.isModerator || privilege.isBroadcaster else {
      member.stopModeration(unavailable: "Moderator or broadcaster evidence required.")
      return
    }

    guard let credentials, let scopes = credentials.scopes, let user = credentials.user,
      chatModerationScopes.allSatisfy({ !$0.isDisjoint(with: scopes) })
    else {
      member.stopModeration(unavailable: "Required moderation scopes are not known to be granted.")
      return
    }

    guard !member.moderationBlocked, member.moderationTask == nil else { return }

    let topic = ChatEventSubTopics.Topic(.channelModerate(broadcasterID: id, moderatorID: user.id))
    startChatModeration(member, topic: topic)
  }

  private func startChatModeration(_ member: Membership, topic: ChatEventSubTopics.Topic) {
    let id = member.channel.id
    let generation = UUID()
    member.moderation = .connecting

    let task = observeChatTopics([topic]) { chat, update in
      chat.acceptModerationTopic(update, id: id, generation: generation)
    }
    member.moderationTask = (generation, task)
  }

  private func acceptModerationTopic(
    _ update: ChatEventSubTopics.Update, id: String, generation: UUID
  ) {
    guard let membership = memberships[id], membership.moderationTask?.generation == generation
    else { return }

    switch update {
    case .ready:
      membership.moderation = .ready
      publishChatState()
    case .event(let notification):
      if let event = notification.event as? ChannelModerateEvent {
        receiveChatModerationEvent(
          event, timestamp: notification.sentAt, channel: membership.channel)
      }
    case .ended(let error):
      endChatModeration(membership, error: error)
    case .setupFailed(let error):
      endChatModeration(membership, error: error)
    }
  }

  private func endChatModeration(_ member: Membership, error: (any Error)?) {
    member.moderationTask = nil
    member.moderationBlocked = true

    if let error = error as? EventSubError, case .revocation(let revocation) = error {
      member.moderationRevocation = revocation.status
    }

    member.moderation =
      error.map { .failed(String(describing: $0)) }
      ?? .unavailable("Moderation subscription ended.")
    publishChatState()
  }
}

private let chatModerationScopes: [Set<String>] = [
  ["moderator:read:blocked_terms", "moderator:manage:blocked_terms"],
  ["moderator:read:chat_settings", "moderator:manage:chat_settings"],
  ["moderator:read:unban_requests", "moderator:manage:unban_requests"],
  ["moderator:read:banned_users", "moderator:manage:banned_users"],
  ["moderator:read:chat_messages", "moderator:manage:chat_messages"],
  ["moderator:read:warnings", "moderator:manage:warnings"],
  ["moderator:read:moderators"], ["moderator:read:vips"],
]
