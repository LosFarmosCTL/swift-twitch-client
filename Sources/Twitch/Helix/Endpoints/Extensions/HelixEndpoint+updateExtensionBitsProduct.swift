import Foundation

extension HelixEndpoint {
  /// Creates or updates a Bits product sold by an extension.
  ///
  /// Twitch requires an app access token for this endpoint. The token’s client ID must
  /// identify the extension.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#update-extension-bits-product
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - sku: The product’s unique SKU.
  ///   - cost: The product’s price and Bits currency.
  ///   - displayName: The display name shown on Twitch.
  ///   - inDevelopment: Whether in development applies, when provided.
  ///   - expiration: The expiration time, when provided.
  ///   - isBroadcast: Whether the product is available for broadcast, when provided.
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

/// The Bits price to assign to an extension product.
public struct ExtensionBitsProductCostRequest: Encodable, Sendable {
  /// The product price in Bits.
  public let amount: Int
  /// The cost currency; Twitch uses `"bits"`.
  public let type: ExtensionBitsProductCostType
}

/// The currency used to price an extension product; Twitch currently uses Bits.
public enum ExtensionBitsProductCostType: String, Codable, Sendable {
  /// Prices the product in Bits.
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
