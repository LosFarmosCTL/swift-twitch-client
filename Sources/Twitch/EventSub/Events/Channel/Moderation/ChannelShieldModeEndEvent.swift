import Foundation

/// An EventSub notification delivered when Shield Mode is disabled.
public struct ChannelShieldModeEndEvent: Event {
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

  /// The time the activity ended.
  public let endedAt: Date

  /// Creates a `ChannelShieldModeEndEvent` value.
  public init(
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    moderatorID: String,
    moderatorLogin: String,
    moderatorDisplayName: String,
    endedAt: Date
  ) {
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.moderatorID = moderatorID
    self.moderatorLogin = moderatorLogin
    self.moderatorDisplayName = moderatorDisplayName
    self.endedAt = endedAt
  }

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorDisplayName = "moderatorUserName"
    case endedAt
  }
}
