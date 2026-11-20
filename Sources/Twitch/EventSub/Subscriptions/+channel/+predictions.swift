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
  public static func channelPredictionBegin(broadcasterID: String)
    -> EventSubSubscription<ChannelPredictionBeginEvent>
  {
    .init(
      type: "channel.prediction.begin", version: "1",
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
  public static func channelPredictionProgress(
    broadcasterID: String
  ) -> EventSubSubscription<ChannelPredictionProgressEvent> {
    .init(
      type: "channel.prediction.progress", version: "1",
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
  public static func channelPredictionLock(broadcasterID: String)
    -> EventSubSubscription<ChannelPredictionLockEvent>
  {
    .init(
      type: "channel.prediction.lock", version: "1",
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
  public static func channelPredictionEnd(broadcasterID: String)
    -> EventSubSubscription<ChannelPredictionEndEvent>
  {
    .init(
      type: "channel.prediction.end", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
