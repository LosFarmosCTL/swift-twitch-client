import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getCharityCampaign()
    -> HelixEndpoint<CharityCampaign?, CharityCampaign, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "charity/campaigns",
      queryItems: { credentials in
        [("broadcaster_id", credentials.userID)]
      },
      makeResponse: { $0.data.first })
  }
}

@MemberwiseInit(.public)
public struct CharityCampaign: Decodable, Sendable {
  public let id: String
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let charityName: String
  public let charityDescription: String
  public let charityLogo: String
  public let charityWebsite: String

  public let currentAmount: CharityAmount
  public let targetAmount: CharityAmount?

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

@MemberwiseInit(.public)
public struct CharityAmount: Decodable, Sendable {
  public let value: Int
  public let decimalPlaces: Int
  public let currency: String
}
