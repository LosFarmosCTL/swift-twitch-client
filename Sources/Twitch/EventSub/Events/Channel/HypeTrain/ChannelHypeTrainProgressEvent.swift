import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelHypeTrainProgressEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let total: Int
  public let progress: Int
  public let goal: Int
  public let level: Int

  public let topContributions: [ChannelHypeTrainBeginEvent.HypeTrainContribution]

  public let startedAt: Date
  public let expiresAt: Date

  public let sharedTrainParticipants: [ChannelHypeTrainBeginEvent.Broadcaster]?
  public let isSharedTrain: Bool

  public let type: ChannelHypeTrainBeginEvent.HypeTrainType

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case total
    case progress
    case goal
    case level
    case topContributions
    case startedAt
    case expiresAt
    case sharedTrainParticipants
    case isSharedTrain
    case type
  }
}
