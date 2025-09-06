public struct CharityCampaignProgressEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let charityName: String
  public let charityDescription: String
  public let charityLogo: String
  public let charityWebsite: String

  public let currentAmount: CharityDonationEvent.CharityAmount
  public let targetAmount: CharityDonationEvent.CharityAmount

  enum CodingKeys: String, CodingKey {
    case id

    case broadcasterID = "broadcasterId"
    case broadcasterLogin, broadcasterName

    case charityName, charityDescription, charityLogo, charityWebsite
    case currentAmount, targetAmount
  }
}
