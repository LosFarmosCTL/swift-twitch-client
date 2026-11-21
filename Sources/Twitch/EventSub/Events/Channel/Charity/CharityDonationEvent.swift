/// An EventSub notification delivered when a viewer donates to a charity campaign.
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
  /// The URL of the charity's logo image.
  public let charityLogo: String
  /// The URL of the charity's website.
  public let charityWebsite: String

  /// The amount contributed or donated.
  public let amount: CharityAmount

  /// Creates a `CharityDonationEvent` value.
  public init(
    id: String,
    campaignID: String,
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    userID: String,
    userLogin: String,
    userDisplayName: String,
    charityName: String,
    charityDescription: String,
    charityLogo: String,
    charityWebsite: String,
    amount: CharityAmount
  ) {
    self.id = id
    self.campaignID = campaignID
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.userID = userID
    self.userLogin = userLogin
    self.userDisplayName = userDisplayName
    self.charityName = charityName
    self.charityDescription = charityDescription
    self.charityLogo = charityLogo
    self.charityWebsite = charityWebsite
    self.amount = amount
  }

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
  public struct CharityAmount: Decodable, Sendable {
    /// The integer monetary amount; divide by ten raised to `decimalPlaces` to obtain
    /// currency units.
    public let value: Int
    /// The number of decimal places used to interpret the integer monetary value.
    public let decimalPlaces: Int
    /// The ISO 4217 currency code.
    public let currency: String

    /// Creates a `CharityAmount` value.
    public init(
      value: Int,
      decimalPlaces: Int,
      currency: String
    ) {
      self.value = value
      self.decimalPlaces = decimalPlaces
      self.currency = currency
    }

    private enum CodingKeys: CodingKey {
      case value, decimalPlaces, decimalPlace, currency
    }

    /// Decodes a charity monetary amount, accepting either `decimal_places` or `decimal_place`.
    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      value = try container.decode(Int.self, forKey: .value)
      currency = try container.decode(String.self, forKey: .currency)
      // Campaign donations use the plural key; chat notices document the singular.
      if container.contains(.decimalPlaces) {
        decimalPlaces = try container.decode(Int.self, forKey: .decimalPlaces)
      } else {
        decimalPlaces = try container.decode(Int.self, forKey: .decimalPlace)
      }
    }
  }
}
