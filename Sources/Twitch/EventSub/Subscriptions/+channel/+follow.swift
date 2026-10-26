extension EventSubSubscription {
  /// Creates a subscription description for channel follow notifications.
  ///
  /// Requires `moderator:read:followers`. With WebSockets, `moderatorID` must match the
  /// token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelfollow
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"2"`.
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
