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
  public static func channelSubscribe(broadcasterID: String)
    -> EventSubSubscription<ChannelSubscribeEvent>
  {
    .init(
      type: "channel.subscribe", version: "1",
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
  public static func channelSubscriptionEnd(broadcasterID: String)
    -> EventSubSubscription<ChannelSubscriptionEndEvent>
  {
    .init(
      type: "channel.subscription.end", version: "1",
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
  public static func channelSubscriptionGift(broadcasterID: String)
    -> EventSubSubscription<ChannelSubscriptionGiftEvent>
  {
    .init(
      type: "channel.subscription.gift", version: "1",
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
  public static func channelSubscriptionMessage(
    broadcasterID: String
  ) -> EventSubSubscription<ChannelSubscriptionMessageEvent> {
    .init(
      type: "channel.subscription.message", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
