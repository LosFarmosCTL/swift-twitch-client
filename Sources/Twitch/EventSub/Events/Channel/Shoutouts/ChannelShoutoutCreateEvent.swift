import Foundation

/// An EventSub notification delivered when a broadcaster sends a shoutout.
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

  /// Creates a `ChannelShoutoutCreateEvent` value.
  public init(
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    toBroadcasterID: String,
    toBroadcasterLogin: String,
    toBroadcasterDisplayName: String,
    moderatorID: String,
    moderatorLogin: String,
    moderatorDisplayName: String,
    viewerCount: Int,
    startedAt: Date,
    cooldownEndsAt: Date,
    targetCooldownEndsAt: Date
  ) {
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.toBroadcasterID = toBroadcasterID
    self.toBroadcasterLogin = toBroadcasterLogin
    self.toBroadcasterDisplayName = toBroadcasterDisplayName
    self.moderatorID = moderatorID
    self.moderatorLogin = moderatorLogin
    self.moderatorDisplayName = moderatorDisplayName
    self.viewerCount = viewerCount
    self.startedAt = startedAt
    self.cooldownEndsAt = cooldownEndsAt
    self.targetCooldownEndsAt = targetCooldownEndsAt
  }

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
