extension EventSubSubscription {
  public static func channelAdBreakBegin(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelAdBreakBeginEvent>
  {
    .init(
      type: EventType.channelAdBreakBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
