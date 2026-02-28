extension EventSubSubscription {
  public static func channelPointsCustomRewardAdd(
    broadcasterID: String, version: String = "1"
  ) -> EventSubSubscription<ChannelPointsCustomRewardAddEvent> {
    .init(
      type: EventType.channelPointsCustomRewardAdd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

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
