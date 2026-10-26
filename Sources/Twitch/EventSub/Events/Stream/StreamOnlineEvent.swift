import Foundation
import MemberwiseInit

/// An EventSub notification delivered when a broadcaster starts streaming.
@MemberwiseInit(.public)
public struct StreamOnlineEvent: Event {
  /// The identifier assigned by Twitch.
  public let id: String

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The stream category, such as live, playlist, or watch party.
  public let type: StreamType
  /// The time the activity started.
  public let startedAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case type
    case startedAt
  }

  /// The kind of broadcast that went online.
  public enum StreamType: String, Codable, Sendable {
    /// A live broadcast.
    case live
    /// A playlist broadcast.
    case playlist
    /// A premiere broadcast.
    case premiere
    /// A replayed broadcast.
    case rerun
    /// A Watch Party broadcast. Encoded as `"watch_party"`.
    case watchParty = "watch_party"
  }
}
