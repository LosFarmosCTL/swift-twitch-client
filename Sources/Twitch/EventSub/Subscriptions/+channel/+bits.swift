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
  public static func channelBitsUse(broadcasterID: String)
    -> EventSubSubscription<ChannelBitsUseEvent>
  {
    .init(
      type: "channel.bits.use", version: "1",
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
  public static func channelCheer(broadcasterID: String)
    -> EventSubSubscription<ChannelCheerEvent>
  {
    .init(
      type: "channel.cheer", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
