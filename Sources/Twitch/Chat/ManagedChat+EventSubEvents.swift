import Foundation

extension ManagedChat {
  func receiveChatEventSub(_ event: any Event, timestamp: Date?, channel: ChatChannel) {
    let id = channel.id
    let payload: ChatEvent.Payload
    var stateChanged = false

    switch event {
    case let event as ChannelChatMessageEvent:
      let message = ChatMessage(eventSub: event)
      stateChanged = observeSenderBadges(
        userID: message.author.id,
        isSourceChannel: event.sourceBroadcasterID == nil || event.sourceBroadcasterID == id,
        in: id, badgeIDs: message.badges.map(\.setID))
      payload = .message(message)

    case let event as ChannelChatNotificationEvent:
      let notification = ChatNotification(eventSub: event)
      stateChanged = observeSenderBadges(
        userID: notification.author?.id,
        isSourceChannel: event.sourceBroadcasterID == nil || event.sourceBroadcasterID == id,
        in: id, badgeIDs: event.badges.map(\.setID))
      payload = .notification(notification)

    case let event as ChannelChatMessageDeleteEvent:
      emitChatDeletion(
        ChatMessageDeletion(
          messageID: event.messageID,
          author: ChatUser(
            id: event.targetID, login: event.targetLogin,
            displayName: event.targetDisplayName),
          text: nil, moderator: nil), channel: channel, timestamp: timestamp)
      return

    case is ChannelChatClearEvent:
      payload = .messagesCleared(user: nil)

    case let event as ChannelChatClearUserMessagesEvent:
      // Clearing effects do not imply a ban or timeout.
      payload = .messagesCleared(
        user: ChatUser(
          id: event.targetID, login: event.targetLogin,
          displayName: event.targetDisplayName))

    case let event as ChannelChatSettingsUpdateEvent:
      receiveEventSubSettings(event, in: channel, timestamp: timestamp)
      return

    default: return
    }

    emitChat(ChatEvent(channel: channel, timestamp: timestamp, payload: payload))
    if stateChanged { publishChatState() }
  }

}
