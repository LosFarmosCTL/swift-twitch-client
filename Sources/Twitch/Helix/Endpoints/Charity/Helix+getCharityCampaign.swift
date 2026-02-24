import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == CharityCampaign?,
  HelixResponseType == CharityCampaign
{
  public static func getCharityCampaign() -> Self {
    return .init(
      method: "GET", path: "charity/campaigns",
      queryItems: { auth in
        [
          ("broadcaster_id", auth.userID)
        ]
      },
      makeResponse: {
        $0.data.first
      })
  }
}

public struct CharityCampaign: Decodable, Sendable {
  public let id: String
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let charityName: String
  public let charityDescription: String
  public let charityLogo: String
  public let charityWebsite: String

  public let currentAmount: CharityAmount
  public let targetAmount: CharityAmount?

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterId"
    case broadcasterLogin, broadcasterName

    case charityName, charityDescription, charityLogo, charityWebsite

    case currentAmount, targetAmount
  }
}

public struct CharityAmount: Decodable, Sendable {
  public let value: Int
  public let decimalPlaces: Int
  public let currency: String
}
