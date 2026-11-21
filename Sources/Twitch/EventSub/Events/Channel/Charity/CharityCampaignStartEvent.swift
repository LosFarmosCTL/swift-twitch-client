import Foundation

/// An EventSub notification delivered when a broadcaster starts a charity campaign.
public struct CharityCampaignStartEvent: Event {
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
  /// The URL of the charity's logo image.
  public let charityLogo: String
  /// The URL of the charity's website.
  public let charityWebsite: String

  /// The amount currently raised.
  public let currentAmount: CharityDonationEvent.CharityAmount
  /// The fundraising target.
  public let targetAmount: CharityDonationEvent.CharityAmount
  /// The time the activity started.
  public let startedAt: Date

  /// Creates a `CharityCampaignStartEvent` value.
  public init(
    id: String,
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    charityName: String,
    charityDescription: String,
    charityLogo: String,
    charityWebsite: String,
    currentAmount: CharityDonationEvent.CharityAmount,
    targetAmount: CharityDonationEvent.CharityAmount,
    startedAt: Date
  ) {
    self.id = id
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.charityName = charityName
    self.charityDescription = charityDescription
    self.charityLogo = charityLogo
    self.charityWebsite = charityWebsite
    self.currentAmount = currentAmount
    self.targetAmount = targetAmount
    self.startedAt = startedAt
  }

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
    case startedAt
  }
}
