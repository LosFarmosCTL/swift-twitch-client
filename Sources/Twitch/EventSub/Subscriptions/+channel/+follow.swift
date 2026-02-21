extension EventSubSubscription where EventNotification == ChannelFollowEvent {
  public static func channelFollow(
    broadcasterID: UserID,
    moderatorID: UserID,
    version: String = "2"
  ) -> Self {
    .init(
      type: EventType.channelFollow.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}
