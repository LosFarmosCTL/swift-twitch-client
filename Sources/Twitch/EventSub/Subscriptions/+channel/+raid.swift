extension EventSubSubscription {
  /// Creates a subscription description for channel raid notifications.
  ///
  /// No event-specific scope is required.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel/#channel-raid
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - fromBroadcasterID: The Twitch user ID of the source broadcaster.
  public static func channelRaid(
    fromBroadcasterID: String
  ) -> EventSubSubscription<ChannelRaidEvent> {
    .init(
      type: "channel.raid", version: "1",
      condition: [
        "from_broadcaster_user_id": fromBroadcasterID
      ])
  }

  /// Creates a subscription description for channel raid notifications.
  ///
  /// No event-specific scope is required.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel/#channel-raid
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - toBroadcasterID: The Twitch user ID of the destination broadcaster.
  public static func channelRaid(
    toBroadcasterID: String
  ) -> EventSubSubscription<ChannelRaidEvent> {
    .init(
      type: "channel.raid", version: "1",
      condition: [
        "to_broadcaster_user_id": toBroadcasterID
      ])
  }
}
