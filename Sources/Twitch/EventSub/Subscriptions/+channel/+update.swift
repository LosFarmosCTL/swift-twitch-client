extension EventSubSubscription {
  public static func channelUpdate(broadcasterID: String, version: String = "2")
    -> EventSubSubscription<ChannelUpdateEvent>
  {
    .init(
      type: EventType.channelUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
