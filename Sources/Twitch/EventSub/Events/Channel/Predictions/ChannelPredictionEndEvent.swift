import Foundation
import MemberwiseInit

/// An EventSub notification delivered when a channel prediction ends.
@MemberwiseInit(.public)
public struct ChannelPredictionEndEvent: Event {
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
  /// The identifier of the winning outcome.
  public let winningOutcomeID: String

  /// Whether the prediction was resolved or canceled.
  public let status: Status
  /// The time the activity started.
  public let startedAt: Date
  /// The time the activity ended.
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

  /// Whether the prediction was resolved or canceled.
  public enum Status: String, Decodable, Sendable {
    /// The prediction has a declared winning outcome.
    case resolved
    /// The operation was cancelled. Encoded as `"canceled"`.
    case cancelled = "canceled"
  }
}
