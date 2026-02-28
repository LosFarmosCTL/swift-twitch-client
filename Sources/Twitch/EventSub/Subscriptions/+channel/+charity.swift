extension EventSubSubscription {
  public static func charityDonation(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<CharityDonationEvent>
  {
    .init(
      type: EventType.charityDonation.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func charityCampaignStart(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<CharityCampaignStartEvent>
  {
    .init(
      type: EventType.charityCampaignStart.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func charityCampaignProgress(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<CharityCampaignProgressEvent>
  {
    .init(
      type: EventType.charityCampaignProgress.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  public static func charityCampaignStop(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<CharityCampaignStopEvent>
  {
    .init(
      type: EventType.charityCampaignStop.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
