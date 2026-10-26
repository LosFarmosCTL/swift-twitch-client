import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct AutoModMessageUpdateEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let userID: String
  public let userLogin: String
  public let userDisplayName: String

  public let moderatorID: String
  public let moderatorDisplayName: String
  public let moderatorLogin: String

  public let messageID: String
  public let message: AutoModMessage

  public let heldAt: Date
  public let reason: AutoModHoldReason
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

  public enum Status: String, Decodable, Sendable {
    case approved, denied, expired
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
