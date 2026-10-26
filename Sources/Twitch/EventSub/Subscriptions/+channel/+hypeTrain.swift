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
  ///   - version: The EventSub subscription schema version. Defaults to `"2"`.
  public static func channelHypeTrainBegin(broadcasterID: String, version: String = "2")
    -> EventSubSubscription<ChannelHypeTrainBeginEvent>
  {
    .init(
      type: EventType.channelHypeTrainBegin.rawValue, version: version,
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
  ///   - version: The EventSub subscription schema version. Defaults to `"2"`.
  public static func channelHypeTrainProgress(
    broadcasterID: String, version: String = "2"
  ) -> EventSubSubscription<ChannelHypeTrainProgressEvent> {
    .init(
      type: EventType.channelHypeTrainProgress.rawValue, version: version,
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
  ///   - version: The EventSub subscription schema version. Defaults to `"2"`.
  public static func channelHypeTrainEnd(broadcasterID: String, version: String = "2")
    -> EventSubSubscription<ChannelHypeTrainEndEvent>
  {
    .init(
      type: EventType.channelHypeTrainEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
