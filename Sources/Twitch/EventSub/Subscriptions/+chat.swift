extension EventSubSubscription where EventNotification == ChatClearEvent {
  public static func chatClear(
    broadcasterID: UserID, userID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.chatClear.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }
}

extension EventSubSubscription where EventNotification == ChatMessageEvent {
  public static func chatMessage(
    broadcasterID: UserID, userID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.chatMessage.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }
}
