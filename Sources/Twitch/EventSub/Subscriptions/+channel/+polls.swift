extension EventSubSubscription {
  public static func channelPollBegin(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelPollBeginEvent>
  {
    .init(
      type: EventType.channelPollBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelPollProgress(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelPollProgressEvent>
  {
    .init(
      type: EventType.channelPollProgress.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelPollEnd(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelPollEndEvent>
  {
    .init(
      type: EventType.channelPollEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
