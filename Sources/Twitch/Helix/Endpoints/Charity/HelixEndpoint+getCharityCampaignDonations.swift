import Foundation
import MemberwiseInit

extension HelixEndpoint {
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

@MemberwiseInit(.public)
public struct CharityDonation: Decodable, Sendable {
  public let id: String
  public let campaignID: String

  public let userID: String
  public let userLogin: String
  public let userDisplayName: String

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
