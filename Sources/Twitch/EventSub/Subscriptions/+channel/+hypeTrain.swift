extension EventSubSubscription {
  /// Creates a subscription description for channel hype train begin notifications.
  ///
  /// Requires `channel:read:hype_train`. The broadcaster must grant the required scope;
  /// with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelhype_trainbegin
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func channelHypeTrainBegin(broadcasterID: String)
    -> EventSubSubscription<ChannelHypeTrainBeginEvent>
  {
    .init(
      type: "channel.hype_train.begin", version: "2",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel hype train progress notifications.
  ///
  /// Requires `channel:read:hype_train`. The broadcaster must grant the required scope;
  /// with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelhype_trainprogress
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func channelHypeTrainProgress(
    broadcasterID: String
  ) -> EventSubSubscription<ChannelHypeTrainProgressEvent> {
    .init(
      type: "channel.hype_train.progress", version: "2",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel hype train end notifications.
  ///
  /// Requires `channel:read:hype_train`. The broadcaster must grant the required scope;
  /// with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelhype_trainend
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func channelHypeTrainEnd(broadcasterID: String)
    -> EventSubSubscription<ChannelHypeTrainEndEvent>
  {
    .init(
      type: "channel.hype_train.end", version: "2",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
