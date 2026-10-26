import Foundation
import MemberwiseInit

/// An EventSub notification delivered when a Guest Star session begins.
@MemberwiseInit(.public)
public struct ChannelGuestStarSessionBeginEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String

  /// The identifier of the session.
  public let sessionID: String
  /// The time the activity started.
  public let startedAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterDisplayName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"
    case sessionID = "sessionId"
    case startedAt
  }
}
