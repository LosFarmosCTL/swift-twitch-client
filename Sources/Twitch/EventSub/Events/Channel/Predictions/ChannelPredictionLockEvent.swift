import Foundation

/// An EventSub notification delivered when a channel prediction is locked.
public struct ChannelPredictionLockEvent: Event {
  /// The identifier assigned by Twitch.
  public let id: String

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The title shown to viewers.
  public let title: String
  /// The prediction outcomes.
  public let outcomes: [ChannelPredictionBeginEvent.Outcome]

  /// The time the activity started.
  public let startedAt: Date
  /// The time the prediction was locked.
  public let lockedAt: Date

  /// Creates a `ChannelPredictionLockEvent` value.
  public init(
    id: String,
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    title: String,
    outcomes: [ChannelPredictionBeginEvent.Outcome] = [],
    startedAt: Date,
    lockedAt: Date
  ) {
    self.id = id
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.title = title
    self.outcomes = outcomes
    self.startedAt = startedAt
    self.lockedAt = lockedAt
  }

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
