extension EventSubSubscription {
  /// Creates a subscription description for channel goal begin notifications.
  ///
  /// Requires `channel:read:goals`. The broadcaster must grant the required scope; with
  /// WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelgoalbegin
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelGoalBegin(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelGoalBeginEvent>
  {
    .init(
      type: EventType.channelGoalBegin.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel goal progress notifications.
  ///
  /// Requires `channel:read:goals`. The broadcaster must grant the required scope; with
  /// WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelgoalprogress
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelGoalProgress(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelGoalProgressEvent>
  {
    .init(
      type: EventType.channelGoalProgress.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel goal end notifications.
  ///
  /// Requires `channel:read:goals`. The broadcaster must grant the required scope; with
  /// WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelgoalend
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelGoalEnd(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelGoalEndEvent>
  {
    .init(
      type: EventType.channelGoalEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
