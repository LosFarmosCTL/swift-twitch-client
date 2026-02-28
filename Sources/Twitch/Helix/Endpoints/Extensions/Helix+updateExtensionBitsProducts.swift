import Foundation

extension HelixEndpoint {
  public static func updateExtensionBitsProduct(
    sku: String,
    cost: ExtensionBitsProductCostRequest,
    displayName: String,
    inDevelopment: Bool? = nil,
    expiration: Date? = nil,
    isBroadcast: Bool? = nil
  ) -> HelixEndpoint<
    [ExtensionBitsProduct], ExtensionBitsProduct,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "PUT", path: "bits/extensions",
      body: { _ in
        UpdateExtensionBitsProductRequestBody(
          sku: sku,
          cost: cost,
          displayName: displayName,
          inDevelopment: inDevelopment,
          expiration: expiration,
          isBroadcast: isBroadcast)
      },
      makeResponse: { $0.data })
  }
}

public struct ExtensionBitsProductCostRequest: Encodable, Sendable {
  public let amount: Int
  public let type: ExtensionBitsProductCostType
}

public enum ExtensionBitsProductCostType: String, Codable, Sendable {
  case bits
}

private struct UpdateExtensionBitsProductRequestBody: Encodable, Sendable {
  let sku: String
  let cost: ExtensionBitsProductCostRequest
  let displayName: String
  let inDevelopment: Bool?
  let expiration: Date?
  let isBroadcast: Bool?
}
