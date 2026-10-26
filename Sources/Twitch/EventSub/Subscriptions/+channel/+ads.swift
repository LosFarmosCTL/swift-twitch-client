extension EventSubSubscription {
  /// Creates a subscription description for channel ad break begin notifications.
  ///
  /// Requires `channel:read:ads`. The broadcaster must grant the required scope; with
  /// WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelad_breakbegin
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelAdBreakBegin(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelAdBreakBeginEvent>
  {
    .init(
      type: EventType.channelAdBreakBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
