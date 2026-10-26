import Foundation
import MemberwiseInit

/// An EventSub notification delivered when a channel prediction is locked.
@MemberwiseInit(.public)
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
