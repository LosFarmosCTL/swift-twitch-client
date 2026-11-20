extension EventSubSubscription {
  /// Creates a subscription description for channel points custom reward add
  /// notifications.
  ///
  /// Requires `channel:read:redemptions` or `channel:manage:redemptions`. The broadcaster
  /// must grant the required scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_rewardadd
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func channelPointsCustomRewardAdd(
    broadcasterID: String
  ) -> EventSubSubscription<ChannelPointsCustomRewardAddEvent> {
    .init(
      type: "channel.channel_points_custom_reward.add", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for channel points custom reward update
  /// notifications.
  ///
  /// Requires `channel:read:redemptions` or `channel:manage:redemptions`. The broadcaster
  /// must grant the required scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_rewardupdate
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - rewardID: A reward ID to filter by; `nil` receives notifications for all
  ///     matching rewards.
  ///
  /// - Returns: A subscription that decodes `ChannelPointsCustomRewardUpdateEvent`
  ///   payloads.
  public static func channelPointsCustomRewardUpdate(
    broadcasterID: String, rewardID: String? = nil
  ) -> EventSubSubscription<ChannelPointsCustomRewardUpdateEvent> {
    var condition: [String: String] = ["broadcaster_user_id": broadcasterID]
    if let rewardID = rewardID {
      condition["reward_id"] = rewardID
    }
    return .init(
      type: "channel.channel_points_custom_reward.update", version: "1",
      condition: condition)
  }

  /// Creates a subscription description for channel points custom reward remove
  /// notifications.
  ///
  /// Requires `channel:read:redemptions` or `channel:manage:redemptions`. The broadcaster
  /// must grant the required scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_rewardremove
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - rewardID: A reward ID to filter by; `nil` receives notifications for all
  ///     matching rewards.
  ///
  /// - Returns: A subscription that decodes `ChannelPointsCustomRewardRemoveEvent`
  ///   payloads.
  public static func channelPointsCustomRewardRemove(
    broadcasterID: String, rewardID: String? = nil
  ) -> EventSubSubscription<ChannelPointsCustomRewardRemoveEvent> {
    var condition: [String: String] = ["broadcaster_user_id": broadcasterID]
    if let rewardID = rewardID {
      condition["reward_id"] = rewardID
    }
    return .init(
      type: "channel.channel_points_custom_reward.remove", version: "1",
      condition: condition)
  }

  /// Creates a subscription description for channel points custom reward redemption add
  /// notifications.
  ///
  /// Requires `channel:read:redemptions` or `channel:manage:redemptions`. The broadcaster
  /// must grant the required scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_reward_redemptionadd
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - rewardID: A reward ID to filter by; `nil` receives notifications for all
  ///     matching rewards.
  ///
  /// - Returns: A subscription that decodes `ChannelPointsCustomRewardRedemptionAddEvent`
  ///   payloads.
  public static func channelPointsCustomRewardRedemptionAdd(
    broadcasterID: String, rewardID: String? = nil
  ) -> EventSubSubscription<ChannelPointsCustomRewardRedemptionAddEvent> {
    var condition: [String: String] = ["broadcaster_user_id": broadcasterID]
    if let rewardID = rewardID {
      condition["reward_id"] = rewardID
    }
    return .init(
      type: "channel.channel_points_custom_reward_redemption.add", version: "1",
      condition: condition)
  }

  /// Creates a subscription description for channel points custom reward redemption
  /// update notifications.
  ///
  /// Requires `channel:read:redemptions` or `channel:manage:redemptions`. The broadcaster
  /// must grant the required scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_reward_redemptionupdate
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - rewardID: A reward ID to filter by; `nil` receives notifications for all
  ///     matching rewards.
  ///
  /// - Returns: A subscription that decodes
  ///   `ChannelPointsCustomRewardRedemptionUpdateEvent` payloads.
  public static func channelPointsCustomRewardRedemptionUpdate(
    broadcasterID: String, rewardID: String? = nil
  ) -> EventSubSubscription<ChannelPointsCustomRewardRedemptionUpdateEvent> {
    var condition: [String: String] = ["broadcaster_user_id": broadcasterID]
    if let rewardID = rewardID {
      condition["reward_id"] = rewardID
    }
    return .init(
      type: "channel.channel_points_custom_reward_redemption.update",
      version: "1",
      condition: condition)
  }

  /// Creates a subscription description for channel points automatic reward redemption
  /// add notifications.
  ///
  /// Requires `channel:read:redemptions` or `channel:manage:redemptions`. The broadcaster
  /// must grant the required scope; with WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_automatic_reward_redemptionadd-v2
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///
  /// - Returns: A subscription that decodes
  ///   `ChannelPointsAutomaticRewardRedemptionAddEvent` payloads.
  public static func channelPointsAutomaticRewardRedemptionAdd(
    broadcasterID: String
  ) -> EventSubSubscription<ChannelPointsAutomaticRewardRedemptionAddEvent> {
    .init(
      type: "channel.channel_points_automatic_reward_redemption.add",
      version: "2",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
