import Foundation

/// An EventSub notification delivered when a held AutoMod message receives a moderation
/// decision.
public struct AutoModMessageUpdateEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  /// The Twitch user ID of the moderator.
  public let moderatorID: String
  /// The display name of the moderator.
  public let moderatorDisplayName: String
  /// The login name of the moderator.
  public let moderatorLogin: String

  /// The identifier of the held message.
  public let messageID: String
  /// The held message's text and content fragments.
  public let message: AutoModMessage

  /// The time Twitch held the message for moderation.
  public let heldAt: Date
  /// Why AutoMod originally held the message.
  public let reason: AutoModHoldReason
  /// Whether the held message was approved, denied, or expired.
  public let status: Status

  /// Creates an `AutoModMessageUpdateEvent` value.
  public init(
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    userID: String,
    userLogin: String,
    userDisplayName: String,
    moderatorID: String,
    moderatorDisplayName: String,
    moderatorLogin: String,
    messageID: String,
    message: AutoModMessage,
    heldAt: Date,
    reason: AutoModHoldReason,
    status: Status
  ) {
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.userID = userID
    self.userLogin = userLogin
    self.userDisplayName = userDisplayName
    self.moderatorID = moderatorID
    self.moderatorDisplayName = moderatorDisplayName
    self.moderatorLogin = moderatorLogin
    self.messageID = messageID
    self.message = message
    self.heldAt = heldAt
    self.reason = reason
    self.status = status
  }

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case moderatorID = "moderatorUserId"
    case moderatorDisplayName = "moderatorUserName"
    case moderatorLogin = "moderatorUserLogin"
    case messageID = "messageId"
    case message
    case heldAt
    case reason
    case autoMod = "automod"
    case blockedTerm
    case status
  }

  /// The approval, denial, or expiration of a held AutoMod message, preserving
  /// unfamiliar values in `rawValue`.
  public struct Status: RawRepresentable, Decodable, Sendable, Hashable {
    /// The exact status string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates a status from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes a status from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// The held message was approved.
    public static let approved = Self(rawValue: "approved")
    /// The held message was denied.
    public static let denied = Self(rawValue: "denied")
    /// The held message expired before a decision.
    public static let expired = Self(rawValue: "expired")
  }

  /// Decodes an AutoMod decision and its reason-specific payload.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    broadcasterDisplayName = try container.decode(
      String.self, forKey: .broadcasterDisplayName)
    userID = try container.decode(String.self, forKey: .userID)
    userLogin = try container.decode(String.self, forKey: .userLogin)
    userDisplayName = try container.decode(String.self, forKey: .userDisplayName)
    moderatorID = try container.decode(String.self, forKey: .moderatorID)
    moderatorDisplayName = try container.decode(
      String.self, forKey: .moderatorDisplayName)
    moderatorLogin = try container.decode(String.self, forKey: .moderatorLogin)
    messageID = try container.decode(String.self, forKey: .messageID)
    message = try container.decode(AutoModMessage.self, forKey: .message)
    heldAt = try container.decode(Date.self, forKey: .heldAt)
    status = try container.decode(Status.self, forKey: .status)
    reason = try AutoModHoldReason(from: decoder)
  }
}
