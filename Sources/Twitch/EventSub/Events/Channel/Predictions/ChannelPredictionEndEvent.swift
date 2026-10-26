import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelPredictionEndEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

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
    case broadcasterDisplayName = "broadcasterUserName"
    case title
    case winningOutcomeID = "winningOutcomeId"
    case outcomes
    case status
    case startedAt
    case endedAt
  }

  public enum Status: String, Decodable, Sendable {
    case resolved
    case cancelled = "canceled"
  }
}
