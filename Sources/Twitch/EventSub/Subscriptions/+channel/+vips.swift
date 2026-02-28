extension EventSubSubscription {
  public static func channelVIPAdd(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelVIPAddEvent>
  {
    .init(
      type: EventType.channelVIPAdd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func channelVIPRemove(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelVIPRemoveEvent>
  {
    .init(
      type: EventType.channelVIPRemove.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
