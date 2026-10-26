import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getDropsEntitlements(
    entitlementIDs: [String] = [],
    userID: String? = nil,
    gameID: String? = nil,
    fulfillmentStatus: DropsEntitlementFulfillmentStatus? = nil,
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (entitlements: [DropsEntitlement], cursor: String?), DropsEntitlement,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "entitlements/drops",
      queryItems: { _ in
        [
          ("user_id", userID),
          ("game_id", gameID),
          ("fulfillment_status", fulfillmentStatus?.rawValue),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ] + entitlementIDs.map { ("id", $0) }
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

@MemberwiseInit(.public)
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
