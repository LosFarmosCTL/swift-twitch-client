extension EventSubSubscription {
  public static func channelFollow(
    broadcasterID: String,
    moderatorID: String,
    version: String = "2"
  ) -> EventSubSubscription<ChannelFollowEvent> {
    .init(
      type: EventType.channelFollow.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}
