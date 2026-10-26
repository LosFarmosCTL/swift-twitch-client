import MemberwiseInit

/// An EventSub notification delivered when a viewer donates to a charity campaign.
@MemberwiseInit(.public)
public struct CharityDonationEvent: Event {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The identifier of the campaign.
  public let campaignID: String

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  /// The name of the charity.
  public let charityName: String
  /// The description of the charity receiving donations.
  public let charityDescription: String
  /// The URL for charity logo.
  public let charityLogo: String
  /// The URL for charity website.
  public let charityWebsite: String

  /// The amount contributed or donated.
  public let amount: CharityAmount

  enum CodingKeys: String, CodingKey {
    case id
    case campaignID = "campaignId"
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case charityName
    case charityDescription
    case charityLogo
    case charityWebsite
    case amount
  }

  /// A monetary amount represented by an integer value, decimal precision, and currency.
  @MemberwiseInit(.public)
  public struct CharityAmount: Decodable, Sendable {
    /// The integer monetary amount; divide by ten raised to `decimalPlaces` to obtain
    /// currency units.
    public let value: Int
    /// The number of decimal places used to interpret the integer monetary value.
    public let decimalPlaces: Int
    /// The ISO 4217 currency code.
    public let currency: String
  }
}
