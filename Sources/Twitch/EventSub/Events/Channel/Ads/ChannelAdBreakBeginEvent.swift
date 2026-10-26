import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelAdBreakBeginEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let requesterID: String
  public let requesterLogin: String
  public let requesterDisplayName: String

  public let durationSeconds: Int
  public let startedAt: Date
  public let isAutomatic: Bool

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case requesterID = "requesterUserId"
    case requesterLogin = "requesterUserLogin"
    case requesterDisplayName = "requesterUserName"
    case durationSeconds
    case isAutomatic
    case startedAt
  }
}
