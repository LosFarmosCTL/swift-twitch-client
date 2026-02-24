extension EventSubSubscription
where EventNotification == ChannelPointsCustomRewardAddEvent {
  public static func channelPointsCustomRewardAdd(
    broadcasterID: String, version: String = "1"
  ) -> Self {
    .init(
      type: EventType.channelPointsCustomRewardAdd.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription
where EventNotification == ChannelPointsCustomRewardUpdateEvent {
  public static func channelPointsCustomRewardUpdate(
    broadcasterID: String, rewardID: String? = nil, version: String = "1"
  ) -> Self {
    var condition: [String: String] = ["broadcaster_user_id": broadcasterID]
    if let rewardID = rewardID {
      condition["reward_id"] = rewardID
    }
    return .init(
      type: EventType.channelPointsCustomRewardUpdate.rawValue, version: version,
      condition: condition)
  }
}

extension EventSubSubscription
where EventNotification == ChannelPointsCustomRewardRemoveEvent {
  public static func channelPointsCustomRewardRemove(
    broadcasterID: String, rewardID: String? = nil, version: String = "1"
  ) -> Self {
    var condition: [String: String] = ["broadcaster_user_id": broadcasterID]
    if let rewardID = rewardID {
      condition["reward_id"] = rewardID
    }
    return .init(
      type: EventType.channelPointsCustomRewardRemove.rawValue, version: version,
      condition: condition)
  }
}

extension EventSubSubscription
where EventNotification == ChannelPointsCustomRewardRedemptionAddEvent {
  public static func channelPointsCustomRewardRedemptionAdd(
    broadcasterID: String, rewardID: String? = nil, version: String = "1"
  ) -> Self {
    var condition: [String: String] = ["broadcaster_user_id": broadcasterID]
    if let rewardID = rewardID {
      condition["reward_id"] = rewardID
    }
    return .init(
      type: EventType.channelPointsCustomRewardRedemptionAdd.rawValue, version: version,
      condition: condition)
  }
}

extension EventSubSubscription
where EventNotification == ChannelPointsCustomRewardRedemptionUpdateEvent {
  public static func channelPointsCustomRewardRedemptionUpdate(
    broadcasterID: String, rewardID: String? = nil, version: String = "1"
  ) -> Self {
    var condition: [String: String] = ["broadcaster_user_id": broadcasterID]
    if let rewardID = rewardID {
      condition["reward_id"] = rewardID
    }
    return .init(
      type: EventType.channelPointsCustomRewardRedemptionUpdate.rawValue,
      version: version,
      condition: condition)
  }
}

extension EventSubSubscription
where EventNotification == ChannelPointsAutomaticRewardRedemptionAddEvent {
  public static func channelPointsAutomaticRewardRedemptionAdd(
    broadcasterID: String, version: String = "2"
  ) -> Self {
    .init(
      type: EventType.channelPointsAutomaticRewardRedemptionAdd.rawValue,
      version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
