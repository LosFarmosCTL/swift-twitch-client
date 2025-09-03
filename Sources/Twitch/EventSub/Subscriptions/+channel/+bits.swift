extension EventSubSubscription where EventNotification == ChannelBitsUseEvent {
  public static func channelBitsUse(broadcasterID: UserID, version: String = "1") -> Self
  {
    .init(
      type: EventType.channelBitsUse.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelCheerEvent {
  public static func channelCheer(broadcasterID: UserID, version: String = "1") -> Self {
    .init(
      type: EventType.channelCheer.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
