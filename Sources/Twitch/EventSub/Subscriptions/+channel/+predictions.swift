extension EventSubSubscription {
  /// Creates a subscription description for channel prediction begin notifications.
  ///
  /// Requires `channel:read:predictions` or `channel:manage:predictions`. The broadcaster
  /// must grant the required scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpredictionbegin
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelPredictionBegin(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelPredictionBeginEvent>
  {
    .init(
      type: EventType.channelPredictionBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel prediction progress notifications.
  ///
  /// Requires `channel:read:predictions` or `channel:manage:predictions`. The broadcaster
  /// must grant the required scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpredictionprogress
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelPredictionProgress(
    broadcasterID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelPredictionProgressEvent> {
    .init(
      type: EventType.channelPredictionProgress.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel prediction lock notifications.
  ///
  /// Requires `channel:read:predictions` or `channel:manage:predictions`. The broadcaster
  /// must grant the required scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpredictionlock
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelPredictionLock(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelPredictionLockEvent>
  {
    .init(
      type: EventType.channelPredictionLock.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel prediction end notifications.
  ///
  /// Requires `channel:read:predictions` or `channel:manage:predictions`. The broadcaster
  /// must grant the required scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelpredictionend
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelPredictionEnd(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelPredictionEndEvent>
  {
    .init(
      type: EventType.channelPredictionEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
