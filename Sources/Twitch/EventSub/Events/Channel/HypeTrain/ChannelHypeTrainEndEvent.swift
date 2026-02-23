import Foundation

public struct ChannelHypeTrainEndEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let total: Int
  public let level: Int

  public let topContributions: [ChannelHypeTrainBeginEvent.HypeTrainContribution]

  public let startedAt: Date
  public let endedAt: Date
  public let cooldownEndsAt: Date

  public let sharedTrainParticipants: [ChannelHypeTrainBeginEvent.Broadcaster]?
  public let isSharedTrain: Bool

  public let type: ChannelHypeTrainBeginEvent.HypeTrainType

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case total, level
    case topContributions

    case startedAt, endedAt, cooldownEndsAt

    case sharedTrainParticipants, isSharedTrain
    case type
  }
}
