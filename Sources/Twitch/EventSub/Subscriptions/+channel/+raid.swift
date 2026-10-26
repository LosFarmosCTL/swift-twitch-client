extension EventSubSubscription {
  /// Creates a subscription description for channel raid notifications.
  ///
  /// No event-specific scope is required.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelraid
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - fromBroadcasterID: The Twitch user ID of the source broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelRaid(
    fromBroadcasterID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelRaidEvent> {
    .init(
      type: EventType.channelRaid.rawValue, version: version,
      condition: [
        "from_broadcaster_user_id": fromBroadcasterID
      ])
  }

  /// Creates a subscription description for channel raid notifications.
  ///
  /// No event-specific scope is required.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelraid
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - toBroadcasterID: The Twitch user ID of the destination broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelRaid(
    toBroadcasterID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelRaidEvent> {
    .init(
      type: EventType.channelRaid.rawValue, version: version,
      condition: [
        "to_broadcaster_user_id": toBroadcasterID
      ])
  }
}
