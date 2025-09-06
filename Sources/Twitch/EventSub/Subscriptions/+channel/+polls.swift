extension EventSubSubscription where EventNotification == ChannelPollBeginEvent {
  public static func channelPollBegin(broadcasterID: UserID, version: String = "1")
    -> Self
  {
    .init(
      type: EventType.channelPollBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelPollProgressEvent {
  public static func channelPollProgress(broadcasterID: UserID, version: String = "1")
    -> Self
  {
    .init(
      type: EventType.channelPollProgress.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelPollEndEvent {
  public static func channelPollEnd(broadcasterID: UserID, version: String = "1") -> Self
  {
    .init(
      type: EventType.channelPollEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
