import MemberwiseInit

/// An EventSub notification delivered when a charity campaign makes progress.
@MemberwiseInit(.public)
public struct CharityCampaignProgressEvent: Event {
  /// The identifier assigned by Twitch.
  public let id: String

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The name of the charity.
  public let charityName: String
  /// The description of the charity receiving donations.
  public let charityDescription: String
  /// The URL for charity logo.
  public let charityLogo: String
  /// The URL for charity website.
  public let charityWebsite: String

  /// The amount currently raised.
  public let currentAmount: CharityDonationEvent.CharityAmount
  /// The fundraising target.
  public let targetAmount: CharityDonationEvent.CharityAmount

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
  }
}
