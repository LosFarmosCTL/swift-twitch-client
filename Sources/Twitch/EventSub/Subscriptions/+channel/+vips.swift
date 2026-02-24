extension EventSubSubscription where EventNotification == ChannelVIPAddEvent {
  public static func channelVIPAdd(broadcasterID: String, version: String = "1") -> Self {
    .init(
      type: EventType.channelVIPAdd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelVIPRemoveEvent {
  public static func channelVIPRemove(broadcasterID: String, version: String = "1")
    -> Self
  {
    .init(
      type: EventType.channelVIPRemove.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
