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
    receivedAt: Date = Date()
  ) {
    // Shared-chat actions affect their source, not automatically the receiving channel.
    if moderation.sourceChannelID == nil || moderation.sourceChannelID == channel.id {
      switch moderation.action {
      case .ban(let user, _) where isChatSender(user):
        senderEvidence[.id(channel.id), default: SenderEvidence()].restriction = .banned
      case .timeout(let user, let until, _, _) where isChatSender(user):
        recordTimeout(until: until, in: channel.id)
      case .unban(let user) where isChatSender(user),
        .untimeout(let user) where isChatSender(user):
        senderEvidence[.id(channel.id), default: SenderEvidence()].restriction = .none
      default: break
      }
    }

    emitChat(
      ChatEvent(
        channel: channel, timestamp: timestamp, receivedAt: receivedAt,
        payload: .moderation(moderation)))
    publishChatState()
  }

  private func recordTimeout(until: Date?, in channelID: String) {
    let key = ChatChannelReference.id(channelID)
    if until == nil,
      case .timedOut(_, let deadline?) = senderEvidence[key]?.restriction,
      deadline > .now
    {
      // An IRC report without a timestamp must not erase a known expiry.
      return
    }
    senderEvidence[key, default: SenderEvidence()].restriction = .timeout(until: until)
  }

  func receiveChatModerationEvent(
    _ event: ChannelModerateEvent, timestamp: Date?, channel: ChatChannel
  ) {
    let id = channel.id
    let receivedAt = Date()
    let moderator = ChatUser(
      id: event.moderatorID, login: event.moderatorLogin,
      displayName: event.moderatorDisplayName)

    switch event.action {
    case .mod(let user), .unmod(let user), .vip(let user), .unvip(let user):
      observeChatModerationRole(event, user: user, in: id)
    default: break
    }

    acceptChatModeration(
      ChatModeration(
        moderator: moderator, sourceChannelID: event.sourceBroadcasterID,
        action: ChatModeration.Action(
          eventSub: event.action, referenceDate: timestamp ?? receivedAt)),
      channel: channel, timestamp: timestamp, receivedAt: receivedAt)
  }

  private func observeChatModerationRole(
    _ event: ChannelModerateEvent, user: ChannelModerateEvent.Action.User, in id: String
  ) {
    if user.userID == credentials.userID,
      event.sourceBroadcasterID == nil || event.sourceBroadcasterID == id
    {
      var privilege = senderEvidence[.id(id)]?.observedPrivilege ?? .unknown

      switch event.action {
      case .mod: privilege.isModerator = true
      case .unmod: privilege.isModerator = false
      case .vip: privilege.isVIP = true
      case .unvip: privilege.isVIP = false
      default: break
      }

      privilege.isKnown = true
      observeChatPrivilege(privilege, in: id)
    }
  }

  private func isChatSender(_ user: ChatUser) -> Bool {
    if let id = user.id {
      return id == credentials.userID
    }

    return user.login?.lowercased() == credentials.userLogin?.lowercased()
      && credentials.userLogin != nil
  }
}
