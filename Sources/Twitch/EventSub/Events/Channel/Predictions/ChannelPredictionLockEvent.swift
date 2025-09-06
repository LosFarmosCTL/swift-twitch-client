import Foundation

public struct ChannelPredictionLockEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let title: String
  public let outcomes: [ChannelPredictionBeginEvent.Outcome]

  public let startedAt: Date
  public let lockedAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case title, outcomes

    case startedAt, lockedAt
  }
}
