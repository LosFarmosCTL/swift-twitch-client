import Foundation
import MemberwiseInit

/// An EventSub notification delivered when AutoMod holds a message for review.
@MemberwiseInit(.public)
public struct AutoModMessageHoldEvent: Event {
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

  /// The identifier of the message.
  public let messageID: String
  /// The message content or explanatory text supplied by Twitch.
  public let message: AutoModMessage

  /// The time Twitch held the message for moderation.
  public let heldAt: Date
  /// The reason supplied for this action.
  public let reason: AutoModHoldReason

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case messageID = "messageId"
    case message
    case heldAt
    case reason
    case autoMod = "automod"
    case blockedTerm
  }

  /// Decodes a held message and its reason-specific payload.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    broadcasterDisplayName = try container.decode(
      String.self, forKey: .broadcasterDisplayName)
    userID = try container.decode(String.self, forKey: .userID)
    userLogin = try container.decode(String.self, forKey: .userLogin)
    userDisplayName = try container.decode(String.self, forKey: .userDisplayName)
    messageID = try container.decode(String.self, forKey: .messageID)
    message = try container.decode(AutoModMessage.self, forKey: .message)
    heldAt = try container.decode(Date.self, forKey: .heldAt)
    reason = try AutoModHoldReason(from: decoder)
  }
}
