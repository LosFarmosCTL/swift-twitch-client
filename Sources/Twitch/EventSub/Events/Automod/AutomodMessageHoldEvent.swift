import Foundation

public struct AutomodMessageHoldEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let userID: String
  public let userLogin: String
  public let userName: String

  public let messageID: String
  public let message: AutomodMessage

  public let heldAt: Date
  public let reason: AutomodHoldReason

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"
    case userID = "userId"
    case userLogin, userName
    case messageID = "messageId"
    case message, heldAt, reason, automod, blockedTerm
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    broadcasterName = try container.decode(String.self, forKey: .broadcasterName)
    userID = try container.decode(String.self, forKey: .userID)
    userLogin = try container.decode(String.self, forKey: .userLogin)
    userName = try container.decode(String.self, forKey: .userName)
    messageID = try container.decode(String.self, forKey: .messageID)
    message = try container.decode(AutomodMessage.self, forKey: .message)
    heldAt = try container.decode(Date.self, forKey: .heldAt)
    reason = try AutomodHoldReason(from: decoder)
  }

  private enum HoldReason: String, Decodable, Sendable {
    case automod = "automod"
    case blockedTerm = "blocked_term"
  }
}
