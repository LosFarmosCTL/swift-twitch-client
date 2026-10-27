import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Updates the fulfillment state of Drops entitlements.
  ///
  /// Accepts a user or app access token without an additional endpoint scope. The token’s
  /// client ID must belong to a member of the organization that owns the game.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#update-drops-entitlements
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - entitlementIDs: The entitlement IDs to include in the request. Defaults to `[]`.
  ///   - fulfillmentStatus: The Drops entitlement’s fulfillment status, when provided.
  public static func updateDropsEntitlements(
    entitlementIDs: [String] = [],
    fulfillmentStatus: DropsEntitlementFulfillmentStatus? = nil
  ) -> HelixEndpoint<
    [DropsEntitlementUpdateResult], DropsEntitlementUpdateResult,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "PATCH", path: "entitlements/drops",
      authentication: .either,
      body: { _ in
        UpdateDropsEntitlementsRequestBody(
          entitlementIDs: entitlementIDs,
          fulfillmentStatus: fulfillmentStatus)
      },
      makeResponse: { $0.data })
  }
}

private struct UpdateDropsEntitlementsRequestBody: Encodable, Sendable {
  let entitlementIDs: [String]
  let fulfillmentStatus: DropsEntitlementFulfillmentStatus?

  enum CodingKeys: String, CodingKey {
    case entitlementIDs = "entitlementIds"
    case fulfillmentStatus
  }
}

/// The outcome of updating one or more Drops entitlements.
@MemberwiseInit(.public)
public struct DropsEntitlementUpdateResult: Decodable, Sendable {
  /// The outcome of updating the entitlements in `entitlementIDs`.
  public let status: DropsEntitlementUpdateStatus
  /// The identifiers associated with this result.
  public let ids: [String]
}

/// The success or failure reported for a batch of Drops entitlement updates.
public enum DropsEntitlementUpdateStatus: String, Decodable, Sendable {
  /// The supplied entitlement ID is invalid. Encoded as `"INVALID_ID"`.
  case invalidID = "INVALID_ID"
  /// The requested entitlement was not found. Encoded as `"NOT_FOUND"`.
  case notFound = "NOT_FOUND"
  /// The update succeeded. Encoded as `"SUCCESS"`.
  case success = "SUCCESS"
  /// The caller is not authorized to update the entitlement. Encoded as `"UNAUTHORIZED"`.
  case unauthorized = "UNAUTHORIZED"
  /// The update failed. Encoded as `"UPDATE_FAILED"`.
  case updateFailed = "UPDATE_FAILED"
}
