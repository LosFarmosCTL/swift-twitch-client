extension EventSubSubscription where EventNotification == ChannelShoutoutCreateEvent {
  public static func channelShoutoutCreate(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelShoutoutCreate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelShoutoutReceiveEvent {
  public static func channelShoutoutReceive(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelShoutoutReceive.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}
