extension EventSubSubscription where EventNotification == ChannelRaidEvent {
  public static func channelRaid(
    fromBroadcasterID: String, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelRaid.rawValue, version: version,
      condition: [
        "from_broadcaster_user_id": fromBroadcasterID
      ])
  }

  public static func channelRaid(
    toBroadcasterID: String, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelRaid.rawValue, version: version,
      condition: [
        "to_broadcaster_user_id": toBroadcasterID
      ])
  }
}
