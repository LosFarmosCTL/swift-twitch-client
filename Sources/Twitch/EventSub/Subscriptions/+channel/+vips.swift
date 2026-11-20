extension EventSubSubscription {
  /// Creates a subscription description for channel VIP add notifications.
  ///
  /// Requires `channel:read:vips` or `channel:manage:vips`. The broadcaster must grant
  /// the required scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel/#channel-vip-add
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func channelVIPAdd(broadcasterID: String)
    -> EventSubSubscription<ChannelVIPAddEvent>
  {
    .init(
      type: "channel.vip.add", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel VIP remove notifications.
  ///
  /// Requires `channel:read:vips` or `channel:manage:vips`. The broadcaster must grant
  /// the required scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel/#channel-vip-remove
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func channelVIPRemove(broadcasterID: String)
    -> EventSubSubscription<ChannelVIPRemoveEvent>
  {
    .init(
      type: "channel.vip.remove", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
