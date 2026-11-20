extension EventSubSubscription {
  /// Creates a subscription description for channel bits use notifications.
  ///
  /// Requires `bits:read`. The broadcaster must grant the required scope; with
  /// WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel/#channel-bits-use
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func channelBitsUse(broadcasterID: String)
    -> EventSubSubscription<ChannelBitsUseEvent>
  {
    .init(
      type: "channel.bits.use", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Observes redemptions of a broadcaster’s custom Bits Power-ups.
  ///
  /// Requires the broadcaster to grant `bits:read`. See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel/#channel-custom-power-up-redemption-add
  /// ).
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - rewardID: One specific Power-up to observe, or `nil` for all custom Power-ups.
  public static func channelCustomPowerUpRedemptionAdd(
    broadcasterID: String, rewardID: String? = nil
  ) -> EventSubSubscription<ChannelCustomPowerUpRedemptionAddEvent> {
    var condition = ["broadcaster_user_id": broadcasterID]
    condition["reward_id"] = rewardID
    return .init(type: "channel.custom_power_up_redemption.add", version: "1", condition: condition)
  }

  /// Creates a subscription description for channel cheer notifications.
  ///
  /// Requires `bits:read`. The broadcaster must grant the required scope; with
  /// WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/reference/channel/#channel-cheer
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func channelCheer(broadcasterID: String)
    -> EventSubSubscription<ChannelCheerEvent>
  {
    .init(
      type: "channel.cheer", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
