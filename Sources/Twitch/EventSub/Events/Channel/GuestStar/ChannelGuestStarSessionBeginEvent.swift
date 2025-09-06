import Foundation

public struct ChannelGuestStarSessionBeginEvent: Event {
  public let broadcasterID: String
  public let broadcasterName: String
  public let broadcasterLogin: String

  public let moderatorID: String
  public let moderatorName: String
  public let moderatorLogin: String

  public let sessionID: String
  public let startedAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"

    case moderatorID = "moderatorUserId"
    case moderatorName = "moderatorUserName"
    case moderatorLogin = "moderatorUserLogin"

    case sessionID = "sessionId"
    case startedAt
  }
}
