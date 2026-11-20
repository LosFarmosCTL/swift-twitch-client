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
  public static func channelPollBegin(broadcasterID: String)
    -> EventSubSubscription<ChannelPollBeginEvent>
  {
    .init(
      type: "channel.poll.begin", version: "1",
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
  public static func channelPollProgress(broadcasterID: String)
    -> EventSubSubscription<ChannelPollProgressEvent>
  {
    .init(
      type: "channel.poll.progress", version: "1",
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
  public static func channelPollEnd(broadcasterID: String)
    -> EventSubSubscription<ChannelPollEndEvent>
  {
    .init(
      type: "channel.poll.end", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
