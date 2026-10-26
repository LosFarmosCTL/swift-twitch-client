import MemberwiseInit

/// An EventSub notification delivered when a suspicious user’s moderation status changes.
@MemberwiseInit(.public)
public struct ChannelSuspiciousUserUpdateEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String

  /// The Twitch user ID of the moderator.
  public let moderatorID: String
  /// The display name of the moderator.
  public let moderatorDisplayName: String
  /// The login name of the moderator.
  public let moderatorLogin: String

  /// The Twitch user ID.
  public let userID: String
  /// The user’s display name.
  public let userDisplayName: String
  /// The user’s login name.
  public let userLogin: String

  /// The moderation status assigned to the suspicious user.
  public let lowTrustStatus: ChannelSuspiciousUserMessageEvent.LowTrustStatus

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterDisplayName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"
    case moderatorID = "moderatorUserId"
    case moderatorDisplayName = "moderatorUserName"
    case moderatorLogin = "moderatorUserLogin"
    case userID = "userId"
    case userDisplayName = "userName"
    case userLogin
    case lowTrustStatus
  }
}
