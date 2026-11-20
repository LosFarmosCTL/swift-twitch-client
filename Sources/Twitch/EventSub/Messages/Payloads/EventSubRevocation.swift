import Foundation

/// Details of a Twitch EventSub subscription revocation.
///
/// Carried by ``EventSubError/revocation(_:)`` when Twitch revokes an active WebSocket
/// subscription, and surfaced in ``ChatDeparture/Reason/subscriptionRevoked(_:)`` and
/// ``ChatChannelState/moderationRevocation`` for managed chat subscriptions.
///
/// - SeeAlso: <doc:EventSub>, ``EventSubError``
public struct EventSubRevocation: Decodable, Sendable {
  internal let subscription: EventSubMessage.Subscription
  /// The reason Twitch revoked the subscription.
  public let status: Status

  /// A Twitch revocation reason, preserving unfamiliar status strings in ``rawValue``.
  public struct Status: RawRepresentable, Decodable, Sendable, Hashable {
    /// The exact revocation status string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates a revocation reason from any raw status string.
    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    /// Decodes a revocation reason from a single JSON string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// The user revoked authorization or the token lost required scopes (`"authorization_revoked"`).
    public static let authorizationRevoked = Self(rawValue: "authorization_revoked")
    /// The user referenced in the subscription condition no longer exists (`"user_removed"`).
    public static let userRemoved = Self(rawValue: "user_removed")
    /// Twitch retired the subscription type or schema version (`"version_removed"`).
    public static let versionRemoved = Self(rawValue: "version_removed")
    /// The subscribed chat user was banned from the channel (`"chat_user_banned"`).
    public static let chatUserBanned = Self(rawValue: "chat_user_banned")
    /// The subscribed chat user was timed out in the channel (`"chat_user_timed_out"`).
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
