import Foundation
import MemberwiseInit

/// An EventSub notification delivered when a broadcaster receives a shoutout.
@MemberwiseInit(.public)
public struct ChannelShoutoutReceiveEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The Twitch user ID of the source broadcaster.
  public let fromBroadcasterID: String
  /// The login name of the source broadcaster.
  public let fromBroadcasterLogin: String
  /// The display name of the source broadcaster.
  public let fromBroadcasterDisplayName: String

  /// The number of viewers reported by Twitch.
  public let viewerCount: Int
  /// The time the activity started.
  public let startedAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case fromBroadcasterID = "fromBroadcasterUserId"
    case fromBroadcasterLogin = "fromBroadcasterUserLogin"
    case fromBroadcasterDisplayName = "fromBroadcasterUserName"
    case viewerCount
    case startedAt
  }
}
