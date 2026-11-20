extension EventSubSubscription {
  /// Creates a subscription description for channel goal begin notifications.
  ///
  /// Requires `channel:read:goals`. The broadcaster must grant the required scope; with
  /// WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/goal/#channel-goal-begin
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func channelGoalBegin(broadcasterID: String)
    -> EventSubSubscription<ChannelGoalBeginEvent>
  {
    .init(
      type: "channel.goal.begin", version: "1",
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
  /// https://dev.twitch.tv/docs/eventsub/reference/goal/#channel-goal-progress
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func channelGoalProgress(broadcasterID: String)
    -> EventSubSubscription<ChannelGoalProgressEvent>
  {
    .init(
      type: "channel.goal.progress", version: "1",
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
  /// https://dev.twitch.tv/docs/eventsub/reference/goal/#channel-goal-end
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func channelGoalEnd(broadcasterID: String)
    -> EventSubSubscription<ChannelGoalEndEvent>
  {
    .init(
      type: "channel.goal.end", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
