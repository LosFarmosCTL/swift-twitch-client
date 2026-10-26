import Foundation
import MemberwiseInit

/// An EventSub notification delivered when an ad break starts.
@MemberwiseInit(.public)
public struct ChannelAdBreakBeginEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The Twitch user ID of the requester.
  public let requesterID: String
  /// The login name of the requester.
  public let requesterLogin: String
  /// The display name of the requester.
  public let requesterDisplayName: String

  /// The duration in seconds.
  public let durationSeconds: Int
  /// The time the activity started.
  public let startedAt: Date
  /// Whether the ad break was started automatically.
  public let isAutomatic: Bool

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case requesterID = "requesterUserId"
    case requesterLogin = "requesterUserLogin"
    case requesterDisplayName = "requesterUserName"
    case durationSeconds
    case isAutomatic
    case startedAt
  }
}
