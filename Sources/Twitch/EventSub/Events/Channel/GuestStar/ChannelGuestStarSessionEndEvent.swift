import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelGuestStarSessionEndEvent: Event {
  public let broadcasterID: String
  public let broadcasterDisplayName: String
  public let broadcasterLogin: String

  public let hostID: String
  public let hostDisplayName: String
  public let hostLogin: String

  public let sessionID: String
  public let startedAt: Date
  public let endedAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterDisplayName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"
    case hostID = "hostUserId"
    case hostDisplayName = "hostUserName"
    case hostLogin = "hostUserLogin"
    case sessionID = "sessionId"
    case startedAt
    case endedAt
  }
}
