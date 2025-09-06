import Foundation

public struct ChannelAdBreakBeginEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let requesterID: String
  public let requesterLogin: String
  public let requesterName: String

  public let durationSeconds: Int
  public let startedAt: Date
  public let isAutomatic: Bool

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case requesterID = "requesterUserId"
    case requesterLogin = "requesterUserLogin"
    case requesterName = "requesterUserName"

    case durationSeconds, isAutomatic, startedAt
  }
}
