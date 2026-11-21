import Foundation

extension HelixEndpoint {
  /// Creates or updates a Bits product sold by an extension.
  ///
  /// Twitch requires an app access token for this endpoint. The token’s client ID must
  /// identify the extension.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/extensions/#update-extension-bits-product
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
  ) -> HelixEndpoint<[ExtensionBitsProduct]> {
    .init(
      method: "PUT", path: "bits/extensions",
      authentication: .app,
      body: { _ in
        UpdateExtensionBitsProductRequestBody(
          sku: sku,
          cost: cost,
          displayName: displayName,
          inDevelopment: inDevelopment,
          expiration: expiration,
          isBroadcast: isBroadcast)
      },
      responseType: ExtensionBitsProduct.self, makeResponse: { $0.data })
  }
}

/// The Bits price to assign to an extension product.
public struct ExtensionBitsProductCostRequest: Encodable, Sendable {
  /// The product price in Bits.
  public let amount: Int
  /// The cost currency; Twitch uses `"bits"`.
  public let type: ExtensionBitsProductCostType

  /// Creates an `ExtensionBitsProductCostRequest` value.
  public init(
    amount: Int,
    type: ExtensionBitsProductCostType
  ) {
    self.amount = amount
    self.type = type
  }
}

/// The currency used to price an extension product, preserving unfamiliar values in
/// `rawValue`.
public struct ExtensionBitsProductCostType: RawRepresentable, Codable, Sendable, Hashable {
  /// The exact cost type string supplied by Twitch or the caller.
  public let rawValue: String

  /// Creates a cost type from any raw string.
  public init(rawValue: String) { self.rawValue = rawValue }

  /// Decodes a cost type from a single string.
  public init(from decoder: Decoder) throws {
    self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
  }

  /// Encodes this cost type as its raw wire string.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }

  /// Prices the product in Bits.
  public static let bits = Self(rawValue: "bits")
}

private struct UpdateExtensionBitsProductRequestBody: Encodable, Sendable {
  let sku: String
  let cost: ExtensionBitsProductCostRequest
  let displayName: String
  let inDevelopment: Bool?
  let expiration: Date?
  let isBroadcast: Bool?
}
