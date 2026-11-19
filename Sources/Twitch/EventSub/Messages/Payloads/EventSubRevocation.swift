import Foundation

/// An EventSub WebSocket revocation payload identifying why a subscription ended.
public struct EventSubRevocation: Decodable, Sendable {
  internal let subscription: EventSubMessage.Subscription
  /// The reason Twitch revoked the subscription.
  public let status: Status

  /// The authorization, user, or schema change that revoked a subscription.
  public enum Status: RawRepresentable, Decodable, Sendable, Hashable {
    /// Authorization for the subscription was revoked. Encoded as
    /// `"authorization_revoked"`.
    case authorizationRevoked
    /// The subscribed user was removed. Encoded as `"user_removed"`.
    case userRemoved
    /// Twitch removed the subscription schema version. Encoded as `"version_removed"`.
    case versionRemoved
    /// The subscribing chat user was banned from the channel.
    case chatUserBanned
    /// The subscribing chat user was timed out in the channel.
    case chatUserTimedOut
    /// A new server reason must still terminate its subscription, not be discarded
    /// as a decoding failure that leaves consumers believing the topic is healthy.
    case unknown(String)

    public init?(rawValue: String) {
      switch rawValue {
      case "authorization_revoked": self = .authorizationRevoked
      case "user_removed": self = .userRemoved
      case "version_removed": self = .versionRemoved
      case "chat_user_banned": self = .chatUserBanned
      case "chat_user_timed_out": self = .chatUserTimedOut
      default: self = .unknown(rawValue)
      }
    }

    public var rawValue: String {
      switch self {
      case .authorizationRevoked: "authorization_revoked"
      case .userRemoved: "user_removed"
      case .versionRemoved: "version_removed"
      case .chatUserBanned: "chat_user_banned"
      case .chatUserTimedOut: "chat_user_timed_out"
      case .unknown(let value): value
      }
    }

    public init(from decoder: any Decoder) throws {
      let value = try decoder.singleValueContainer().decode(String.self)
      self = Status(rawValue: value)!
    }
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
