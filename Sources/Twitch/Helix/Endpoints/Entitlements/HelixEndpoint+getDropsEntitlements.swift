import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets Drops entitlements matching the supplied filters.
  ///
  /// Accepts a user or app access token without an additional endpoint scope. The token’s
  /// client ID must belong to a member of the organization that owns the game.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-drops-entitlements
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - entitlementIDs: The entitlement IDs to include in the request. Defaults to `[]`.
  ///   - userID: The Twitch user ID, when provided.
  ///   - gameID: The identifier of the game, when provided.
  ///   - fulfillmentStatus: The Drops entitlement’s fulfillment status, when provided.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields matching items and a pagination cursor when
  ///   executed. The cursor is `nil` when there is no next page.
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

/// A user’s entitlement to a Drops benefit and its fulfillment state.
@MemberwiseInit(.public)
public struct DropsEntitlement: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The identifier of the benefit.
  public let benefitID: String
  /// The timestamp supplied by Twitch.
  public let timestamp: Date
  /// The Twitch user ID.
  public let userID: String
  /// The identifier of the game.
  public let gameID: String
  /// The Drops entitlement’s fulfillment status.
  public let fulfillmentStatus: DropsEntitlementFulfillmentStatus
  /// The time the resource was last updated.
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

/// Whether a Drops entitlement has been claimed or fulfilled.
public enum DropsEntitlementFulfillmentStatus: String, Codable, Sendable {
  /// The Drops entitlement has been claimed. Encoded as `"CLAIMED"`.
  case claimed = "CLAIMED"
  /// The reward or entitlement has been fulfilled. Encoded as `"FULFILLED"`.
  case fulfilled = "FULFILLED"
}
