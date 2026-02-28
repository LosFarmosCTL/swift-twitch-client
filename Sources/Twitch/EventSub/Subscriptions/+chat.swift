extension EventSubSubscription {
  public static func chatClear(
    broadcasterID: String, userID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelChatClearEvent> {
    .init(
      type: EventType.channelChatClear.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  public static func chatClearUserMessages(
    broadcasterID: String, userID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelChatClearUserMessagesEvent> {
    .init(
      type: EventType.channelChatClearUserMessages.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  public static func chatMessage(
    broadcasterID: String, userID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelChatMessageEvent> {
    .init(
      type: EventType.channelChatMessage.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  public static func channelChatMessageDelete(
    broadcasterID: String, userID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelChatMessageDeleteEvent> {
    .init(
      type: EventType.channelChatMessageDelete.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  public static func channelChatNotification(
    broadcasterID: String, userID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelChatNotificationEvent> {
    .init(
      type: EventType.channelChatNotification.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  public static func channelChatSettingsUpdate(
    broadcasterID: String, userID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelChatSettingsUpdateEvent> {
    .init(
      type: EventType.channelChatSettingsUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  public static func channelChatUserMessageHold(
    broadcasterID: String, userID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelChatUserMessageHoldEvent> {
    .init(
      type: EventType.channelChatUserMessageHold.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }

  public static func channelChatUserMessageUpdate(
    broadcasterID: String, userID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelChatUserMessageUpdateEvent> {
    .init(
      type: EventType.channelChatUserMessageUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }
}
