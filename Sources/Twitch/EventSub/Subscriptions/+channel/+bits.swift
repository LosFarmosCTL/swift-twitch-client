extension EventSubSubscription {
  /// Creates a subscription description for channel bits use notifications.
  ///
  /// Requires `bits:read`. The broadcaster must grant the required scope; with
  /// WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelbitsuse
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelBitsUse(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelBitsUseEvent>
  {
    .init(
      type: EventType.channelBitsUse.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel cheer notifications.
  ///
  /// Requires `bits:read`. The broadcaster must grant the required scope; with
  /// WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcheer
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelCheer(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelCheerEvent>
  {
    .init(
      type: EventType.channelCheer.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
