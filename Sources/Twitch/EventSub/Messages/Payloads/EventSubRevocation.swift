import Foundation

/// An EventSub WebSocket revocation payload identifying why a subscription ended.
public struct EventSubRevocation: Decodable, Sendable {
  internal let subscription: EventSubMessage.Subscription
  /// The reason Twitch revoked the subscription.
  public let status: Status

  /// A Twitch revocation reason. Unfamiliar reasons are preserved in `rawValue`.
  public struct Status: RawRepresentable, Decodable, Sendable, Hashable {
    /// The exact revocation reason supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates a revocation reason from any string.
    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    /// Decodes a revocation reason from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// Authorization for the subscription was revoked. Encoded as
    /// `"authorization_revoked"`.
    public static let authorizationRevoked = Self(rawValue: "authorization_revoked")
    /// The subscribed user was removed. Encoded as `"user_removed"`.
    public static let userRemoved = Self(rawValue: "user_removed")
    /// Twitch removed the subscription schema version. Encoded as `"version_removed"`.
    public static let versionRemoved = Self(rawValue: "version_removed")
    /// The subscribing chat user was banned from the channel.
    public static let chatUserBanned = Self(rawValue: "chat_user_banned")
    /// The subscribing chat user was timed out in the channel.
    public static let chatUserTimedOut = Self(rawValue: "chat_user_timed_out")
  }

  enum SubscriptionKeys: CodingKey { case status }

  enum CodingKeys: CodingKey {
    case subscription
  }

  /// Decodes a revocation, extracting the subscription ID and status.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    subscription = try container.decode(EventSubMessage.Subscription.self, forKey: .subscription)
    let fields = try container.nestedContainer(
      keyedBy: SubscriptionKeys.self, forKey: .subscription)

    status = try fields.decode(Status.self, forKey: .status)
  }
}
