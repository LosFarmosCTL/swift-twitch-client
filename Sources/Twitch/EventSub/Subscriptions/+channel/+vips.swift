extension EventSubSubscription where EventNotification == ChannelVIPAddEvent {
  public static func channelVIPAdd(broadcasterID: UserID, version: String = "1") -> Self {
    .init(
      type: EventType.channelVIPAdd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelVIPRemoveEvent {
  public static func channelVIPRemove(broadcasterID: UserID, version: String = "1")
    -> Self
  {
    .init(
      type: EventType.channelVIPRemove.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
