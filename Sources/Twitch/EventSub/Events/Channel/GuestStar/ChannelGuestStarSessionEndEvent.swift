import Foundation

public struct ChannelGuestStarSessionEndEvent: Event {
  public let broadcasterID: String
  public let broadcasterName: String
  public let broadcasterLogin: String

  public let hostID: String
  public let hostName: String
  public let hostLogin: String

  public let sessionID: String
  public let startedAt: Date
  public let endedAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"

    case hostID = "hostUserId"
    case hostName = "hostUserName"
    case hostLogin = "hostUserLogin"

    case sessionID = "sessionId"
    case startedAt, endedAt
  }
}
