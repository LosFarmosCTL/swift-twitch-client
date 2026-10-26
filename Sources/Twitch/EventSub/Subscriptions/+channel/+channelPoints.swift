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
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func channelPointsCustomRewardAdd(
    broadcasterID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelPointsCustomRewardAddEvent> {
    .init(
      type: EventType.channelPointsCustomRewardAdd.rawValue, version: version,
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
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  ///
  /// - Returns: A subscription that decodes `ChannelPointsCustomRewardUpdateEvent`
  ///   payloads.
  public static func channelPointsCustomRewardUpdate(
    broadcasterID: String, rewardID: String? = nil, version: String = "1"
  ) -> EventSubSubscription<ChannelPointsCustomRewardUpdateEvent> {
    var condition: [String: String] = ["broadcaster_user_id": broadcasterID]
    if let rewardID = rewardID {
      condition["reward_id"] = rewardID
    }
    return .init(
      type: EventType.channelPointsCustomRewardUpdate.rawValue, version: version,
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
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  ///
  /// - Returns: A subscription that decodes `ChannelPointsCustomRewardRemoveEvent`
  ///   payloads.
  public static func channelPointsCustomRewardRemove(
    broadcasterID: String, rewardID: String? = nil, version: String = "1"
  ) -> EventSubSubscription<ChannelPointsCustomRewardRemoveEvent> {
    var condition: [String: String] = ["broadcaster_user_id": broadcasterID]
    if let rewardID = rewardID {
      condition["reward_id"] = rewardID
    }
    return .init(
      type: EventType.channelPointsCustomRewardRemove.rawValue, version: version,
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
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  ///
  /// - Returns: A subscription that decodes `ChannelPointsCustomRewardRedemptionAddEvent`
  ///   payloads.
  public static func channelPointsCustomRewardRedemptionAdd(
    broadcasterID: String, rewardID: String? = nil, version: String = "1"
  ) -> EventSubSubscription<ChannelPointsCustomRewardRedemptionAddEvent> {
    var condition: [String: String] = ["broadcaster_user_id": broadcasterID]
    if let rewardID = rewardID {
      condition["reward_id"] = rewardID
    }
    return .init(
      type: EventType.channelPointsCustomRewardRedemptionAdd.rawValue, version: version,
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
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  ///
  /// - Returns: A subscription that decodes
  ///   `ChannelPointsCustomRewardRedemptionUpdateEvent` payloads.
  public static func channelPointsCustomRewardRedemptionUpdate(
    broadcasterID: String, rewardID: String? = nil, version: String = "1"
  ) -> EventSubSubscription<ChannelPointsCustomRewardRedemptionUpdateEvent> {
    var condition: [String: String] = ["broadcaster_user_id": broadcasterID]
    if let rewardID = rewardID {
      condition["reward_id"] = rewardID
    }
    return .init(
      type: EventType.channelPointsCustomRewardRedemptionUpdate.rawValue,
      version: version,
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
  ///   - version: The EventSub subscription schema version. Defaults to `"2"`.
  ///
  /// - Returns: A subscription that decodes
  ///   `ChannelPointsAutomaticRewardRedemptionAddEvent` payloads.
  public static func channelPointsAutomaticRewardRedemptionAdd(
    broadcasterID: String, version: String = "2"
  ) -> EventSubSubscription<ChannelPointsAutomaticRewardRedemptionAddEvent> {
    .init(
      type: EventType.channelPointsAutomaticRewardRedemptionAdd.rawValue,
      version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
