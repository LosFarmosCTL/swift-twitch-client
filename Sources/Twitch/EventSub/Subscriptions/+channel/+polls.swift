extension EventSubSubscription {
  /// Creates a subscription description for channel poll begin notifications.
  ///
  /// Requires `channel:read:polls` or `channel:manage:polls`. The broadcaster must grant
  /// the required scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpollbegin
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelPollBegin(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelPollBeginEvent>
  {
    .init(
      type: EventType.channelPollBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel poll progress notifications.
  ///
  /// Requires `channel:read:polls` or `channel:manage:polls`. The broadcaster must grant
  /// the required scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpollprogress
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelPollProgress(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelPollProgressEvent>
  {
    .init(
      type: EventType.channelPollProgress.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel poll end notifications.
  ///
  /// Requires `channel:read:polls` or `channel:manage:polls`. The broadcaster must grant
  /// the required scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpollend
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelPollEnd(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelPollEndEvent>
  {
    .init(
      type: EventType.channelPollEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
