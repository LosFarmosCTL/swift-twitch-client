import Foundation

/// An EventSub WebSocket revocation payload identifying why a subscription ended.
public struct EventSubRevocation: Decodable, Sendable {
  internal let subscriptionID: String
  /// The reason Twitch revoked the subscription.
  public let status: Status

  /// The authorization, user, or schema change that revoked a subscription.
  public enum Status: String, Decodable, Sendable {
    /// Authorization for the subscription was revoked. Encoded as
    /// `"authorization_revoked"`.
    case authorizationRevoked = "authorization_revoked"
    /// The subscribed user was removed. Encoded as `"user_removed"`.
    case userRemoved = "user_removed"
    /// Twitch removed the subscription schema version. Encoded as `"version_removed"`.
    case versionRemoved = "version_removed"
  }

  struct Subscription: Decodable {
    let id: String
    let status: Status
  }

  enum CodingKeys: CodingKey {
    case subscription
  }

  /// Decodes a revocation, extracting the subscription ID and status.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let subscription = try container.decode(Subscription.self, forKey: .subscription)

    self.status = subscription.status
    self.subscriptionID = subscription.id
  }
}
