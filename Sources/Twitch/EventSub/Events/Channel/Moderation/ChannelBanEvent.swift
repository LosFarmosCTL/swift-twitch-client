import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelBanEvent: Event {
  public let userID: String
  public let userLogin: String
  public let userDisplayName: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let moderatorID: String
  public let moderatorLogin: String
  public let moderatorDisplayName: String

  public let reason: String
  public let bannedAt: Date
  public let endsAt: Date?
  public let isPermanent: Bool

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorDisplayName = "moderatorUserName"
    case reason
    case bannedAt
    case endsAt
    case isPermanent
  }
}
