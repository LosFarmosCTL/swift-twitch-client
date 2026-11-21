import Foundation

/// An EventSub notification delivered when a Hype Train receives contributions.
public struct ChannelHypeTrainProgressEvent: Event {
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
  /// The progress reported for the current level.
  public let progress: Int
  /// The goal required to complete this level.
  public let goal: Int
  /// The current level.
  public let level: Int

  /// The largest Hype Train contributions.
  public let topContributions: [ChannelHypeTrainBeginEvent.HypeTrainContribution]

  /// The time the activity started.
  public let startedAt: Date
  /// The time the resource expires.
  public let expiresAt: Date

  /// The channels participating in the shared Hype Train, when provided.
  public let sharedTrainParticipants: [ChannelHypeTrainBeginEvent.Broadcaster]?
  /// Whether the Hype Train spans multiple channels.
  public let isSharedTrain: Bool

  /// The Hype Train category reported by Twitch.
  public let type: ChannelHypeTrainBeginEvent.HypeTrainType

  /// Creates a `ChannelHypeTrainProgressEvent` value.
  public init(
    id: String,
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    total: Int,
    progress: Int,
    goal: Int,
    level: Int,
    topContributions: [ChannelHypeTrainBeginEvent.HypeTrainContribution] = [],
    startedAt: Date,
    expiresAt: Date,
    sharedTrainParticipants: [ChannelHypeTrainBeginEvent.Broadcaster]? = nil,
    isSharedTrain: Bool,
    type: ChannelHypeTrainBeginEvent.HypeTrainType
  ) {
    self.id = id
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.total = total
    self.progress = progress
    self.goal = goal
    self.level = level
    self.topContributions = topContributions
    self.startedAt = startedAt
    self.expiresAt = expiresAt
    self.sharedTrainParticipants = sharedTrainParticipants
    self.isSharedTrain = isSharedTrain
    self.type = type
  }

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
