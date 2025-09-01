import Foundation

public struct AutomodMessageUpdateEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let userID: String
  public let userLogin: String
  public let userName: String

  public let moderatorID: String
  public let moderatorName: String
  public let moderatorLogin: String

  public let messageID: String
  public let message: AutomodMessage

  public let heldAt: Date
  public let reason: AutomodHoldReason
  public let status: Status

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"
    case userID = "userId"
    case userLogin, userName
    case moderatorID = "moderatorUserId"
    case moderatorName = "moderatorUserName"
    case moderatorLogin = "moderatorUserLogin"
    case messageID = "messageId"
    case message, heldAt, reason, automod, blockedTerm, status
  }

  public enum Status: String, Decodable, Sendable {
    case approved, denied, expired
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    broadcasterName = try container.decode(String.self, forKey: .broadcasterName)
    userID = try container.decode(String.self, forKey: .userID)
    userLogin = try container.decode(String.self, forKey: .userLogin)
    userName = try container.decode(String.self, forKey: .userName)
    moderatorID = try container.decode(String.self, forKey: .moderatorID)
    moderatorName = try container.decode(String.self, forKey: .moderatorName)
    moderatorLogin = try container.decode(String.self, forKey: .moderatorLogin)
    messageID = try container.decode(String.self, forKey: .messageID)
    message = try container.decode(AutomodMessage.self, forKey: .message)
    heldAt = try container.decode(Date.self, forKey: .heldAt)
    status = try container.decode(Status.self, forKey: .status)
    reason = try AutomodHoldReason(from: decoder)
  }
}
