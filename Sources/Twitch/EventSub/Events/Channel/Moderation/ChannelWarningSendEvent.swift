import MemberwiseInit

/// An EventSub notification delivered when a moderator warns a user.
@MemberwiseInit(.public)
public struct ChannelWarningSendEvent: Event {
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

  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  /// The reason supplied for this action, when provided.
  public let reason: String?
  /// The channel chat rules cited in the warning, when provided.
  public let chatRulesCited: [String]?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorDisplayName = "moderatorUserName"
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case reason
    case chatRulesCited
  }
}
