import Foundation
import MemberwiseInit

/// An EventSub notification delivered when a held AutoMod message receives a moderation
/// decision.
@MemberwiseInit(.public)
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

  /// The identifier of the message.
  public let messageID: String
  /// The message content or explanatory text supplied by Twitch.
  public let message: AutoModMessage

  /// The time Twitch held the message for moderation.
  public let heldAt: Date
  /// The reason supplied for this action.
  public let reason: AutoModHoldReason
  /// Whether the held message was approved, denied, or expired.
  public let status: Status

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

  /// The approval, denial, or expiration of a held AutoMod message.
  public enum Status: String, Decodable, Sendable {
    /// The held message was approved.
    case approved
    /// The held message was denied.
    case denied
    /// The held message expired before a decision.
    case expired
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
