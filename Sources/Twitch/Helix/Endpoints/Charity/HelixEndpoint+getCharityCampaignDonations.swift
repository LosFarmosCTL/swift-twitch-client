import Foundation

extension HelixEndpoint {
  /// Gets donations to the broadcaster’s active charity campaign.
  ///
  /// With a user access token, requires `channel:read:charity`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/charity/#get-charity-campaign-donations
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - cursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields matching items and a pagination cursor when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getCharityCampaignDonations(
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<CharityCampaignDonationsResponse> {
    .init(
      method: "GET", path: "charity/donations",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", try credentials.requireUserID(parameter: "broadcaster_id")),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      },
      responseType: CharityDonation.self,
      makeResponse: {
        CharityCampaignDonationsResponse(
          donations: $0.data, cursor: $0.pagination?.cursor)
      })
  }
}

/// A viewer’s donation to a charity campaign.
public struct CharityDonation: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The identifier of the campaign.
  public let campaignID: String

  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  /// The amount contributed or donated.
  public let amount: CharityAmount

  /// Creates a `CharityDonation` value.
  public init(
    id: String,
    campaignID: String,
    userID: String,
    userLogin: String,
    userDisplayName: String,
    amount: CharityAmount
  ) {
    self.id = id
    self.campaignID = campaignID
    self.userID = userID
    self.userLogin = userLogin
    self.userDisplayName = userDisplayName
    self.amount = amount
  }

  enum CodingKeys: String, CodingKey {
    case id
    case campaignID = "campaignId"
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case amount
  }
}

/// A page of charity campaign donations.
public struct CharityCampaignDonationsResponse: Sendable {
  /// The donations on this page.
  public let donations: [CharityDonation]
  /// The next-page cursor, if Twitch returned one.
  public let cursor: String?

  /// Creates a `CharityCampaignDonationsResponse` value.
  public init(
    donations: [CharityDonation] = [],
    cursor: String? = nil
  ) {
    self.donations = donations
    self.cursor = cursor
  }
}
