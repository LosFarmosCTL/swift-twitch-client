extension EventSubSubscription {
  /// Creates a subscription description for channel VIP add notifications.
  ///
  /// Requires `channel:read:vips` or `channel:manage:vips`. The broadcaster must grant
  /// the required scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelvipadd
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelVIPAdd(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelVIPAddEvent>
  {
    .init(
      type: EventType.channelVIPAdd.rawValue, version: version,
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
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelvipremove
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelVIPRemove(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelVIPRemoveEvent>
  {
    .init(
      type: EventType.channelVIPRemove.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
