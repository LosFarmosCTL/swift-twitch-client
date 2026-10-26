import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct AutoModMessageHoldEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let userID: String
  public let userLogin: String
  public let userDisplayName: String

  public let messageID: String
  public let message: AutoModMessage

  public let heldAt: Date
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
