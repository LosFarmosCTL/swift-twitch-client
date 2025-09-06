import Foundation

public struct ChannelBanEvent: Event {
  public let userID: String
  public let userLogin: String
  public let userName: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let moderatorID: String
  public let moderatorLogin: String
  public let moderatorName: String

  public let reason: String
  public let bannedAt: Date
  public let endsAt: Date?
  public let isPermanent: Bool

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin, userName

    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorName = "moderatorUserName"

    case reason
    case bannedAt, endsAt
    case isPermanent
  }
}
