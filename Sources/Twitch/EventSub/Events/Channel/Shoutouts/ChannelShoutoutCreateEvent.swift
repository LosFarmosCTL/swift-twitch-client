import Foundation
import MemberwiseInit

/// An EventSub notification delivered when a broadcaster sends a shoutout.
@MemberwiseInit(.public)
public struct ChannelShoutoutCreateEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The Twitch user ID of the destination broadcaster.
  public let toBroadcasterID: String
  /// The login name of the destination broadcaster.
  public let toBroadcasterLogin: String
  /// The display name of the destination broadcaster.
  public let toBroadcasterDisplayName: String

  /// The Twitch user ID of the moderator.
  public let moderatorID: String
  /// The login name of the moderator.
  public let moderatorLogin: String
  /// The display name of the moderator.
  public let moderatorDisplayName: String

  /// The number of viewers reported by Twitch.
  public let viewerCount: Int
  /// The time the activity started.
  public let startedAt: Date
  /// The time the cooldown ends.
  public let cooldownEndsAt: Date
  /// The time the shoutout cooldown for this target ends.
  public let targetCooldownEndsAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case toBroadcasterID = "toBroadcasterUserId"
    case toBroadcasterLogin = "toBroadcasterUserLogin"
    case toBroadcasterDisplayName = "toBroadcasterUserName"
    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorDisplayName = "moderatorUserName"
    case viewerCount
    case startedAt
    case cooldownEndsAt
    case targetCooldownEndsAt
  }
}
