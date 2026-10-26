import Foundation
import MemberwiseInit

/// An EventSub notification delivered when a user is banned or timed out in a channel.
@MemberwiseInit(.public)
public struct ChannelBanEvent: Event {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The Twitch user ID of the moderator.
  public let moderatorID: String
  /// The login name of the moderator.
  public let moderatorLogin: String
  /// The display name of the moderator.
  public let moderatorDisplayName: String

  /// The reason supplied for this action.
  public let reason: String
  /// The time the ban or timeout was applied.
  public let bannedAt: Date
  /// The scheduled end time, when provided.
  public let endsAt: Date?
  /// Whether the ban is permanent.
  public let isPermanent: Bool

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorDisplayName = "moderatorUserName"
    case reason
    case bannedAt
    case endsAt
    case isPermanent
  }
}
