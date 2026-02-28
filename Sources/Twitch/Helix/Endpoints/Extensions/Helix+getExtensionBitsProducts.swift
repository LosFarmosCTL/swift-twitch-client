import Foundation

extension HelixEndpoint {
  public static func getExtensionBitsProducts(
    includeAll: Bool? = nil
  ) -> HelixEndpoint<
    [ExtensionBitsProduct], ExtensionBitsProduct,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "bits/extensions",
      queryItems: { _ in
        [("should_include_all", includeAll.map(String.init))]
      },
      makeResponse: { $0.data })
  }
}

public struct ExtensionBitsProduct: Decodable, Sendable {
  public let sku: String
  public let cost: ExtensionBitsProductCost
  public let isInDevelopment: Bool
  public let displayName: String
  public let expiration: Date?
  public let isBroadcast: Bool

  enum CodingKeys: String, CodingKey {
    case sku, cost
    case isInDevelopment = "inDevelopment"
    case displayName, expiration, isBroadcast
  }
}

public struct ExtensionBitsProductCost: Decodable, Sendable {
  public let amount: Int
  public let type: ExtensionBitsProductCostType
}
