extension EventSubSubscription {
  /// Creates a subscription description for channel follow notifications.
  ///
  /// Requires `moderator:read:followers`. With WebSockets, `moderatorID` must match the
  /// token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel/#channel-follow
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  public static func channelFollow(
    broadcasterID: String,
    moderatorID: String
  ) -> EventSubSubscription<ChannelFollowEvent> {
    .init(
      type: "channel.follow", version: "2",
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}
