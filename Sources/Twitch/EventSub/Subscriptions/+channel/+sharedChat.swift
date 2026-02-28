extension EventSubSubscription {
  public static func channelSharedChatSessionBegin(
    broadcasterID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelSharedChatSessionBeginEvent> {
    .init(
      type: EventType.channelSharedChatSessionBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelSharedChatSessionUpdate(
    broadcasterID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelSharedChatSessionUpdateEvent> {
    .init(
      type: EventType.channelSharedChatSessionUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelSharedChatSessionEnd(
    broadcasterID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelSharedChatSessionEndEvent> {
    .init(
      type: EventType.channelSharedChatSessionEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
