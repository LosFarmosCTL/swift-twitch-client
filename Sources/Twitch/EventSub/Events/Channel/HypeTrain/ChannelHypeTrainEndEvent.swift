import Foundation
import MemberwiseInit

/// An EventSub notification delivered when a Hype Train ends.
@MemberwiseInit(.public)
public struct ChannelHypeTrainEndEvent: Event {
  /// The identifier assigned by Twitch.
  public let id: String

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The cumulative contribution points earned during this Hype Train.
  public let total: Int
  /// The current level.
  public let level: Int

  /// The largest Hype Train contributions.
  public let topContributions: [ChannelHypeTrainBeginEvent.HypeTrainContribution]

  /// The time the activity started.
  public let startedAt: Date
  /// The time the activity ended.
  public let endedAt: Date
  /// The time the cooldown ends.
  public let cooldownEndsAt: Date

  /// The channels participating in the shared Hype Train, when provided.
  public let sharedTrainParticipants: [ChannelHypeTrainBeginEvent.Broadcaster]?
  /// Whether the Hype Train spans multiple channels.
  public let isSharedTrain: Bool

  /// The Hype Train category reported by Twitch.
  public let type: ChannelHypeTrainBeginEvent.HypeTrainType

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case total
    case level
    case topContributions
    case startedAt
    case endedAt
    case cooldownEndsAt
    case sharedTrainParticipants
    case isSharedTrain
    case type
  }
}
