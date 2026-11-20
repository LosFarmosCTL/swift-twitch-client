extension EventSubSubscription {
  /// Creates a subscription description for channel ad break begin notifications.
  ///
  /// Requires `channel:read:ads`. The broadcaster must grant the required scope; with
  /// WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel/#channel-ad-break-begin
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func channelAdBreakBegin(broadcasterID: String)
    -> EventSubSubscription<ChannelAdBreakBeginEvent>
  {
    .init(
      type: "channel.ad_break.begin", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
