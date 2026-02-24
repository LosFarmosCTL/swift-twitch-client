import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ([DropsEntitlement], PaginationCursor?),
  HelixResponseType == DropsEntitlement
{
  public static func getDropsEntitlements(
    ids: [String] = [],
    userID: UserID? = nil,
    gameID: String? = nil,
    fulfillmentStatus: DropsEntitlementFulfillmentStatus? = nil,
    limit: Int? = nil,
    after cursor: PaginationCursor? = nil
  ) -> Self {
    return .init(
      method: "GET", path: "entitlements/drops",
      queryItems: { _ in
        [
          ("user_id", userID),
          ("game_id", gameID),
          ("fulfillment_status", fulfillmentStatus?.rawValue),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ] + ids.map { ("id", $0) }
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

public struct DropsEntitlement: Decodable, Sendable {
  public let id: String
  public let benefitID: String
  public let timestamp: Date
  public let userID: String
  public let gameID: String
  public let fulfillmentStatus: DropsEntitlementFulfillmentStatus
  public let lastUpdated: Date

  enum CodingKeys: String, CodingKey {
    case id
    case benefitID = "benefitId"
    case timestamp
    case userID = "userId"
    case gameID = "gameId"
    case fulfillmentStatus
    case lastUpdated
  }
}

public enum DropsEntitlementFulfillmentStatus: String, Codable, Sendable {
  case claimed = "CLAIMED"
  case fulfilled = "FULFILLED"
}
