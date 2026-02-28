extension EventSubSubscription {
  public static func channelShoutoutCreate(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelShoutoutCreateEvent> {
    .init(
      type: EventType.channelShoutoutCreate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  public static func channelShoutoutReceive(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelShoutoutReceiveEvent> {
    .init(
      type: EventType.channelShoutoutReceive.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}
