import Foundation

public struct ChannelPredictionEndEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let title: String
  public let outcomes: [ChannelPredictionBeginEvent.Outcome]
  public let winningOutcomeID: String

  public let status: Status
  public let startedAt: Date
  public let endedAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case title
    case winningOutcomeID = "winningOutcomeId"

    case outcomes, status

    case startedAt, endedAt
  }

  public enum Status: String, Decodable, Sendable {
    case resolved, canceled
  }
}
