import Foundation

extension HelixEndpoint {
  public static func getCharityCampaignDonations(
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<
    ([CharityDonation], String?), CharityDonation, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "charity/donations",
      queryItems: { auth in
        [
          ("broadcaster_id", auth.userID),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

public struct CharityDonation: Decodable, Sendable {
  public let id: String
  public let campaignID: String

  public let userID: String
  public let userLogin: String
  public let userName: String

  public let amount: CharityAmount

  enum CodingKeys: String, CodingKey {
    case id
    case campaignID = "campaignId"

    case userID = "userId"
    case userLogin, userName

    case amount
  }
}
