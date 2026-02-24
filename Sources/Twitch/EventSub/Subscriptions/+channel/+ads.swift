extension EventSubSubscription where EventNotification == ChannelAdBreakBeginEvent {
  public static func channelAdBreakBegin(broadcasterID: String, version: String = "1")
    -> Self
  {
    .init(
      type: EventType.channelAdBreakBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
