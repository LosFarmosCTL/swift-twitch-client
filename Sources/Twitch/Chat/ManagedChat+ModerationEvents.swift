import Foundation

extension ManagedChat {
  internal func emitChatDeletion(
    _ deletion: ChatMessageDeletion, channel: ChatChannel, timestamp: Date?,
    receivedAt: Date = Date()
  ) {
    guard memberships[channel.id]?.deletedMessageIDs.insert(deletion.messageID) == true else {
      return
    }
    emitChat(
      ChatEvent(
        channel: channel, timestamp: timestamp, receivedAt: receivedAt,
        payload: .messageDeleted(deletion)))
  }

  internal func acceptChatModeration(
    _ moderation: ChatModeration, channel: ChatChannel, timestamp: Date?,
    receivedAt: Date = Date(),
    stateChanged: Bool = false
  ) {
    var didChangeState = stateChanged

    // Shared-chat actions affect their source, not automatically the receiving channel.
    if moderation.sourceChannelID == nil || moderation.sourceChannelID == channel.id {
      switch moderation.action {
      case .ban(let user, _) where isChatSender(user):
        if senderEvidence.recordBan(for: channel.id) { didChangeState = true }
      case .timeout(let user, let until, _, _) where isChatSender(user):
        if senderEvidence.recordTimeout(until: until, for: channel.id) { didChangeState = true }
      case .unban(let user) where isChatSender(user),
        .untimeout(let user) where isChatSender(user):
        if senderEvidence.clearRestriction(for: channel.id) { didChangeState = true }
      default: break
      }
    }

    emitChat(
      ChatEvent(
        channel: channel, timestamp: timestamp, receivedAt: receivedAt,
        payload: .moderation(moderation)))
    if didChangeState { publishChatState() }
  }

  func receiveChatModerationEvent(
    _ event: ChannelModerateEvent, timestamp: Date?, channel: ChatChannel
  ) {
    let id = channel.id
    let receivedAt = Date()
    let moderator = ChatUser(
      id: event.moderatorID, login: event.moderatorLogin,
      displayName: event.moderatorDisplayName)

    var stateChanged = false
    switch event.action {
    case .mod(let user), .unmod(let user), .vip(let user), .unvip(let user):
      stateChanged = observeChatModerationRole(event, user: user, in: id)
    default: break
    }

    acceptChatModeration(
      ChatModeration(
        moderator: moderator, sourceChannelID: event.sourceBroadcasterID,
        action: ChatModeration.Action(
          eventSub: event.action, referenceDate: timestamp ?? receivedAt)),
      channel: channel, timestamp: timestamp, receivedAt: receivedAt,
      stateChanged: stateChanged)
  }

  private func observeChatModerationRole(
    _ event: ChannelModerateEvent, user: ChannelModerateEvent.Action.User, in id: String
  ) -> Bool {
    guard let userID = credentials?.userID, user.userID == userID,
      event.sourceBroadcasterID == nil || event.sourceBroadcasterID == id
    else { return false }

    var privilege = senderEvidence.observedPrivilege(for: id) ?? .unknown

    switch event.action {
    case .mod: privilege.isModerator = true
    case .unmod: privilege.isModerator = false
    case .vip: privilege.isVIP = true
    case .unvip: privilege.isVIP = false
    default: break
    }

    privilege.isKnown = true
    return observeChatPrivilege(privilege, in: id)
  }

  private func isChatSender(_ user: ChatUser) -> Bool {
    if let id = user.id {
      return id == credentials?.userID
    }

    guard let login = credentials?.userLogin else { return false }
    return user.login?.lowercased() == login
  }
}
