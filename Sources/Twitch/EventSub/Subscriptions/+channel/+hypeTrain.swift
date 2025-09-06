extension EventSubSubscription where EventNotification == ChannelHypeTrainBeginEvent {
  public static func channelHypeTrainBegin(broadcasterID: UserID, version: String = "2")
    -> Self
  {
    .init(
      type: EventType.channelHypeTrainBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelHypeTrainProgressEvent {
  public static func channelHypeTrainProgress(
    broadcasterID: UserID, version: String = "2"
  ) -> Self {
    .init(
      type: EventType.channelHypeTrainProgress.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelHypeTrainEndEvent {
  public static func channelHypeTrainEnd(broadcasterID: UserID, version: String = "2")
    -> Self
  {
    .init(
      type: EventType.channelHypeTrainEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
