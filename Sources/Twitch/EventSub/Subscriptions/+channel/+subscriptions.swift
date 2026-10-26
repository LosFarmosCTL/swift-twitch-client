extension EventSubSubscription {
  /// Creates a subscription description for channel subscribe notifications.
  ///
  /// Requires `channel:read:subscriptions`. The broadcaster must grant the required
  /// scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsubscribe
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelSubscribe(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelSubscribeEvent>
  {
    .init(
      type: EventType.channelSubscribe.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel subscription end notifications.
  ///
  /// Requires `channel:read:subscriptions`. The broadcaster must grant the required
  /// scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsubscriptionend
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelSubscriptionEnd(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelSubscriptionEndEvent>
  {
    .init(
      type: EventType.channelSubscriptionEnd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel subscription gift notifications.
  ///
  /// Requires `channel:read:subscriptions`. The broadcaster must grant the required
  /// scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsubscriptiongift
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelSubscriptionGift(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<ChannelSubscriptionGiftEvent>
  {
    .init(
      type: EventType.channelSubscriptionGift.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel subscription message notifications.
  ///
  /// Requires `channel:read:subscriptions`. The broadcaster must grant the required
  /// scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelsubscriptionmessage
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelSubscriptionMessage(
    broadcasterID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelSubscriptionMessageEvent> {
    .init(
      type: EventType.channelSubscriptionMessage.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
