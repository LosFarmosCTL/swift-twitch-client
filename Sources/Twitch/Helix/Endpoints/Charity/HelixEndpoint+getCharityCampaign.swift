import Foundation

extension HelixEndpoint {
  /// Gets the broadcaster’s active charity campaign.
  ///
  /// With a user access token, requires `channel:read:charity`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/charity/#get-charity-campaign
  /// ) for request limits and account requirements.
  ///
  /// - Returns: An endpoint that yields the active campaign when executed, or `nil` when
  ///   Twitch returns no active campaign.
  public static func getCharityCampaign()
    -> HelixEndpoint<CharityCampaign?>
  {
    .init(
      method: "GET", path: "charity/campaigns",
      authentication: .user,
      queryItems: { credentials in
        [("broadcaster_id", try credentials.requireUserID(parameter: "broadcaster_id"))]
      },
      responseType: CharityCampaign.self, makeResponse: { $0.data.first })
  }
}

/// A broadcaster’s active charity fundraiser and its current and target amounts.
public struct CharityCampaign: Decodable, Sendable {
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
  public let currentAmount: CharityAmount
  /// The fundraising target, when provided.
  public let targetAmount: CharityAmount?

  /// Creates a `CharityCampaign` value.
  public init(
    id: String,
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    charityName: String,
    charityDescription: String,
    charityLogo: String,
    charityWebsite: String,
    currentAmount: CharityAmount,
    targetAmount: CharityAmount? = nil
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
  }
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
}
