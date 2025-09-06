extension EventSubSubscription where EventNotification == ChannelUpdateEvent {
  public static func channelUpdate(broadcasterID: UserID, version: String = "2") -> Self {
    .init(
      type: EventType.channelUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
