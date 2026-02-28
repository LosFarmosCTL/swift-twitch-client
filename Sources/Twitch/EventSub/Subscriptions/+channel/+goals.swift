extension EventSubSubscription {
  public static func channelGoalBegin(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelGoalBeginEvent>
  {
    .init(
      type: EventType.channelGoalBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelGoalProgress(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelGoalProgressEvent>
  {
    .init(
      type: EventType.channelGoalProgress.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelGoalEnd(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelGoalEndEvent>
  {
    .init(
      type: EventType.channelGoalEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
