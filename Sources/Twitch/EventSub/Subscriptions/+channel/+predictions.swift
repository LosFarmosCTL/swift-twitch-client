extension EventSubSubscription {
  public static func channelPredictionBegin(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelPredictionBeginEvent>
  {
    .init(
      type: EventType.channelPredictionBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelPredictionProgress(
    broadcasterID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelPredictionProgressEvent> {
    .init(
      type: EventType.channelPredictionProgress.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelPredictionLock(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelPredictionLockEvent>
  {
    .init(
      type: EventType.channelPredictionLock.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelPredictionEnd(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelPredictionEndEvent>
  {
    .init(
      type: EventType.channelPredictionEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
