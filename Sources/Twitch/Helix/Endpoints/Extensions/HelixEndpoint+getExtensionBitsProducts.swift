import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets the Bits products sold by an extension.
  ///
  /// Twitch requires an app access token for this endpoint. The token’s client ID must
  /// identify the extension.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-extension-bits-products
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - includeAll: Whether to include all available entries.
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

/// A purchasable extension product and its Bits cost and availability.
@MemberwiseInit(.public)
public struct ExtensionBitsProduct: Decodable, Sendable {
  /// The product’s unique SKU.
  public let sku: String
  /// The product’s price and Bits currency.
  public let cost: ExtensionBitsProductCost
  /// Whether the product is in development.
  public let isInDevelopment: Bool
  /// The display name shown on Twitch.
  public let displayName: String
  /// The expiration time, when provided.
  public let expiration: Date?
  /// Whether the product is available for broadcast.
  public let isBroadcast: Bool

  enum CodingKeys: String, CodingKey {
    case sku, cost
    case isInDevelopment = "inDevelopment"
    case displayName, expiration, isBroadcast
  }
}

/// The cost and currency of an extension Bits product.
@MemberwiseInit(.public)
public struct ExtensionBitsProductCost: Decodable, Sendable {
  /// The product price in Bits.
  public let amount: Int
  /// The cost currency; Twitch uses `"bits"`.
  public let type: ExtensionBitsProductCostType
}
