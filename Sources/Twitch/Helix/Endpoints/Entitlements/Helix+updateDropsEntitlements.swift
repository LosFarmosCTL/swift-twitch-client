import Foundation

extension HelixEndpoint {
  public static func updateDropsEntitlements(
    entitlementIDs: [String] = [],
    fulfillmentStatus: DropsEntitlementFulfillmentStatus? = nil
  ) -> HelixEndpoint<
    [DropsEntitlementUpdateResult], DropsEntitlementUpdateResult,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "PATCH", path: "entitlements/drops",
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

public struct DropsEntitlementUpdateResult: Decodable, Sendable {
  public let status: DropsEntitlementUpdateStatus
  public let ids: [String]
}

public enum DropsEntitlementUpdateStatus: String, Decodable, Sendable {
  case invalidID = "INVALID_ID"
  case notFound = "NOT_FOUND"
  case success = "SUCCESS"
  case unauthorized = "UNAUTHORIZED"
  case updateFailed = "UPDATE_FAILED"
}
