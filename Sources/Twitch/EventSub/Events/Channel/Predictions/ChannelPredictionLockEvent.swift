import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelPredictionLockEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let title: String
  public let outcomes: [ChannelPredictionBeginEvent.Outcome]

  public let startedAt: Date
  public let lockedAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case title
    case outcomes
    case startedAt
    case lockedAt
  }
}
