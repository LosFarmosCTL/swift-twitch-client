extension EventSubSubscription {
  public static func channelBitsUse(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelBitsUseEvent>
  {
    .init(
      type: EventType.channelBitsUse.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelCheer(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelCheerEvent>
  {
    .init(
      type: EventType.channelCheer.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
