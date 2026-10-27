import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets purchases of an extension’s digital products.
  ///
  /// Requires an app access token whose client ID identifies the extension.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-extension-transactions
  /// ) for authorization and request limits.
  ///
  /// - Parameters:
  ///   - extensionID: The extension’s client ID.
  ///   - transactionIDs: Up to 100 transaction IDs; an empty array requests all purchases.
  ///   - limit: The page size, from 1 through 100; `nil` uses Twitch’s default.
  ///   - afterCursor: The next-page cursor, if any.
  /// - Returns: Transactions and the cursor for the next page.
  public static func getExtensionTransactions(
    extensionID: String,
    transactionIDs: [String] = [],
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (transactions: [ExtensionTransaction], cursor: String?), ExtensionTransaction,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "extensions/transactions",
      queryItems: { _ in
        [
          ("extension_id", extensionID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ] + transactionIDs.map { ("id", $0) }
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

/// The purchase of an extension’s digital product.
@MemberwiseInit(.public)
public struct ExtensionTransaction: Decodable, Sendable {
  /// The transaction ID.
  public let id: String
  /// When the purchase occurred.
  public let timestamp: Date
  /// The broadcaster’s user ID.
  public let broadcasterID: String
  /// The broadcaster’s login name.
  public let broadcasterLogin: String
  /// The broadcaster’s display name.
  public let broadcasterDisplayName: String
  /// The purchaser’s user ID.
  public let userID: String
  /// The purchaser’s login name.
  public let userLogin: String
  /// The purchaser’s display name.
  public let userDisplayName: String
  /// The transaction type; Twitch currently returns `BITS_IN_EXTENSION`.
  public let productType: String
  /// Details of the purchased product.
  public let productData: Product

  enum CodingKeys: String, CodingKey {
    case id, timestamp
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterDisplayName = "broadcasterName"
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case productType, productData
  }

  /// A digital product recorded in an extension transaction.
  @MemberwiseInit(.public)
  public struct Product: Decodable, Sendable {
    /// The product’s SKU.
    public let sku: String
    /// The extension’s product namespace.
    public let domain: String
    /// The price and currency exchanged.
    public let cost: ExtensionBitsProductCost
    /// Whether the product is in development.
    public let isInDevelopment: Bool
    /// The product’s display name.
    public let displayName: String
    /// Twitch currently returns an empty string because expired products cannot be bought.
    public let expiration: String
    /// Whether the purchase was broadcast to all extension instances.
    public let isBroadcast: Bool

    enum CodingKeys: String, CodingKey {
      case sku, domain, cost, displayName, expiration
      case isInDevelopment = "inDevelopment"
      case isBroadcast = "broadcast"
    }
  }
}
