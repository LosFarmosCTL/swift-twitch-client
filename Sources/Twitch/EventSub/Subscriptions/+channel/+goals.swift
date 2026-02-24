extension EventSubSubscription where EventNotification == ChannelGoalBeginEvent {
  public static func channelGoalBegin(broadcasterID: String, version: String = "1")
    -> Self
  {
    .init(
      type: EventType.channelGoalBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelGoalProgressEvent {
  public static func channelGoalProgress(broadcasterID: String, version: String = "1")
    -> Self
  {
    .init(
      type: EventType.channelGoalProgress.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelGoalEndEvent {
  public static func channelGoalEnd(broadcasterID: String, version: String = "1") -> Self
  {
    .init(
      type: EventType.channelGoalEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
