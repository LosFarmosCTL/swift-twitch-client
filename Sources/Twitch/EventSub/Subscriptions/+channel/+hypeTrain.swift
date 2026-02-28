extension EventSubSubscription {
  public static func channelHypeTrainBegin(broadcasterID: String, version: String = "2")
    -> EventSubSubscription<ChannelHypeTrainBeginEvent>
  {
    .init(
      type: EventType.channelHypeTrainBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelHypeTrainProgress(
    broadcasterID: String, version: String = "2"
  ) -> EventSubSubscription<ChannelHypeTrainProgressEvent> {
    .init(
      type: EventType.channelHypeTrainProgress.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelHypeTrainEnd(broadcasterID: String, version: String = "2")
    -> EventSubSubscription<ChannelHypeTrainEndEvent>
  {
    .init(
      type: EventType.channelHypeTrainEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
