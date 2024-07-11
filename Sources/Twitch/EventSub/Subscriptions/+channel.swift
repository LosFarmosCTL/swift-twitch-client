extension EventSubSubscription where EventNotification == ChannelUpdateEvent {
  public static func channelUpdate(broadcasterID: UserID, version: String = "2") -> Self {
    .init(
      type: EventType.channelUpdate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == ChannelFollowEvent {
  public static func channelFollow(broadcasterID: UserID, version: String = "1") -> Self {
    .init(
      type: EventType.channelFollow.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
