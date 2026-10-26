extension EventSubSubscription {
  /// Creates a subscription description for channel shoutout create notifications.
  ///
  /// Requires `moderator:read:shoutouts` or `moderator:manage:shoutouts`. With
  /// WebSockets, `moderatorID` must match the token’s user, who must be the broadcaster
  /// or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshoutoutcreate
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelShoutoutCreate(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelShoutoutCreateEvent> {
    .init(
      type: EventType.channelShoutoutCreate.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }

  /// Creates a subscription description for channel shoutout receive notifications.
  ///
  /// Requires `moderator:read:shoutouts` or `moderator:manage:shoutouts`. With
  /// WebSockets, `moderatorID` must match the token’s user, who must be the broadcaster
  /// or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelshoutoutreceive
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The Twitch user ID of the moderator.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelShoutoutReceive(
    broadcasterID: String, moderatorID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelShoutoutReceiveEvent> {
    .init(
      type: EventType.channelShoutoutReceive.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID,
        "moderator_user_id": moderatorID,
      ])
  }
}
