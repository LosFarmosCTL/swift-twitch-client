import Foundation

extension HelixEndpoint {
  /// Updates the fulfillment state of Drops entitlements.
  ///
  /// Accepts a user or app access token without an additional endpoint scope. The token’s
  /// client ID must belong to a member of the organization that owns the game.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/entitlements/#update-drops-entitlements
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - entitlementIDs: The entitlement IDs to include in the request. Defaults to `[]`.
  ///   - fulfillmentStatus: The Drops entitlement’s fulfillment status, when provided.
  public static func updateDropsEntitlements(
    entitlementIDs: [String] = [],
    fulfillmentStatus: DropsEntitlementFulfillmentStatus? = nil
  ) -> HelixEndpoint<[DropsEntitlementUpdateResult]> {
    .init(
      method: "PATCH", path: "entitlements/drops",
      authentication: .either,
      body: { _ in
        UpdateDropsEntitlementsRequestBody(
          entitlementIDs: entitlementIDs,
          fulfillmentStatus: fulfillmentStatus)
      },
      responseType: DropsEntitlementUpdateResult.self, makeResponse: { $0.data })
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
public struct DropsEntitlementUpdateResult: Decodable, Sendable {
  /// The outcome of updating the entitlements in `entitlementIDs`.
  public let status: DropsEntitlementUpdateStatus
  /// The identifiers associated with this result.
  public let ids: [String]

  /// Creates a `DropsEntitlementUpdateResult` value.
  public init(
    status: DropsEntitlementUpdateStatus,
    ids: [String] = []
  ) {
    self.status = status
    self.ids = ids
  }
}

/// The success or failure reported for a batch of Drops entitlement updates, preserving
/// unfamiliar values in `rawValue`.
public struct DropsEntitlementUpdateStatus: RawRepresentable, Decodable, Sendable, Hashable {
  /// The exact update status string supplied by Twitch or the caller.
  public let rawValue: String

  /// Creates an update status from any raw string.
  public init(rawValue: String) { self.rawValue = rawValue }

  /// Decodes an update status from a single string.
  public init(from decoder: Decoder) throws {
    self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
  }

  /// The supplied entitlement ID is invalid. Encoded as `"INVALID_ID"`.
  public static let invalidID = Self(rawValue: "INVALID_ID")
  /// The requested entitlement was not found. Encoded as `"NOT_FOUND"`.
  public static let notFound = Self(rawValue: "NOT_FOUND")
  /// The update succeeded. Encoded as `"SUCCESS"`.
  public static let success = Self(rawValue: "SUCCESS")
  /// The caller is not authorized to update the entitlement. Encoded as `"UNAUTHORIZED"`.
  public static let unauthorized = Self(rawValue: "UNAUTHORIZED")
  /// The update failed. Encoded as `"UPDATE_FAILED"`.
  public static let updateFailed = Self(rawValue: "UPDATE_FAILED")
}
