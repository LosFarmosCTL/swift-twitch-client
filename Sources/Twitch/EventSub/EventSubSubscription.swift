public struct EventSubSubscription<EventNotification: Event> {
  let type: String
  let version: String
  let condition: [String: String]
}

extension EventSubSubscription where EventNotification == ChannelUpdateEvent {
  public static func channelUpdate(broadcasterID: UserID, version: String = "2") -> Self {
    .init(
      type: "channel.update", version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChatClearEvent {
  public static func chatClear(
    broadcasterID: UserID, userID: UserID, version: String = "1"
  ) -> Self {
    .init(
      type: "channel.chat.clear", version: version,
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
      type: "channel.chat.message", version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "user_id": userID,
      ])
  }
}
