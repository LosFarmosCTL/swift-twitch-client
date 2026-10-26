import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct CharityCampaignStopEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let charityName: String
  public let charityDescription: String
  public let charityLogo: String
  public let charityWebsite: String

  public let currentAmount: CharityDonationEvent.CharityAmount
  public let targetAmount: CharityDonationEvent.CharityAmount
  public let stoppedAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterDisplayName = "broadcasterName"
    case charityName
    case charityDescription
    case charityLogo
    case charityWebsite
    case currentAmount
    case targetAmount
    case stoppedAt
  }
}
