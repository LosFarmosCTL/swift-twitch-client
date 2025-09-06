extension EventSubSubscription where EventNotification == CharityDonationEvent {
  public static func charityDonation(broadcasterID: UserID, version: String = "1") -> Self
  {
    .init(
      type: EventType.charityDonation.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == CharityCampaignStartEvent {
  public static func charityCampaignStart(broadcasterID: UserID, version: String = "1")
    -> Self
  {
    .init(
      type: EventType.charityCampaignStart.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == CharityCampaignProgressEvent {
  public static func charityCampaignProgress(broadcasterID: UserID, version: String = "1")
    -> Self
  {
    .init(
      type: EventType.charityCampaignProgress.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}

extension EventSubSubscription where EventNotification == CharityCampaignStopEvent {
  public static func charityCampaignStop(broadcasterID: UserID, version: String = "1")
    -> Self
  {
    .init(
      type: EventType.charityCampaignStop.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
