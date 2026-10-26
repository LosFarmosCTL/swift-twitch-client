import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets donations to the broadcaster’s active charity campaign.
  ///
  /// With a user access token, requires `channel:read:charity`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-charity-campaign-donations
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields matching items and a pagination cursor when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getCharityCampaignDonations(
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (donations: [CharityDonation], cursor: String?),
    CharityDonation, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "charity/donations",
      queryItems: { credentials in
        [
          ("broadcaster_id", credentials.userID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

/// A viewer’s donation to a charity campaign.
@MemberwiseInit(.public)
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

  enum CodingKeys: String, CodingKey {
    case id
    case campaignID = "campaignId"
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case amount
  }
}
