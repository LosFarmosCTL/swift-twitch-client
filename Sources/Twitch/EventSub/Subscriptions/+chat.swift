extension EventSubSubscription where EventNotification == ChannelChatClearEvent {
  public static func chatClear(
    broadcasterID: UserID, userID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelChatClear.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }
}

extension EventSubSubscription
where EventNotification == ChannelChatClearUserMessagesEvent {
  public static func chatClearUserMessages(
    broadcasterID: UserID, userID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelChatClearUserMessages.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelChatMessageEvent {
  public static func chatMessage(
    broadcasterID: UserID, userID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelChatMessage.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelChatMessageDeleteEvent {
  public static func channelChatMessageDelete(
    broadcasterID: UserID, userID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelChatMessageDelete.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelChatNotificationEvent {
  public static func channelChatNotification(
    broadcasterID: UserID, userID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelChatNotification.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelChatSettingsUpdateEvent {
  public static func channelChatSettingsUpdate(
    broadcasterID: UserID, userID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelChatSettingsUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }
}

extension EventSubSubscription
where EventNotification == ChannelChatUserMessageHoldEvent {
  public static func channelChatUserMessageHold(
    broadcasterID: UserID, userID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelChatUserMessageHold.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }
}

extension EventSubSubscription
where EventNotification == ChannelChatUserMessageUpdateEvent {
  public static func channelChatUserMessageUpdate(
    broadcasterID: UserID, userID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelChatUserMessageUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }
}
