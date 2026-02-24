extension EventSubSubscription where EventNotification == ChannelPredictionBeginEvent {
  public static func channelPredictionBegin(broadcasterID: String, version: String = "1")
    -> Self
  {
    .init(
      type: EventType.channelPredictionBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelPredictionProgressEvent {
  public static func channelPredictionProgress(
    broadcasterID: String, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelPredictionProgress.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelPredictionLockEvent {
  public static func channelPredictionLock(broadcasterID: String, version: String = "1")
    -> Self
  {
    .init(
      type: EventType.channelPredictionLock.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelPredictionEndEvent {
  public static func channelPredictionEnd(broadcasterID: String, version: String = "1")
    -> Self
  {
    .init(
      type: EventType.channelPredictionEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
