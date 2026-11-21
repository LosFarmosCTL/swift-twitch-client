import Foundation

/// An EventSub notification delivered when a Guest Star session ends.
///
/// Uses Twitch’s beta Guest Star schema, which Twitch may change without notice.
public struct ChannelGuestStarSessionEndEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String

  /// The Twitch user ID of the host.
  public let hostID: String
  /// The display name of the host.
  public let hostDisplayName: String
  /// The login name of the host.
  public let hostLogin: String

  /// The identifier of the session.
  public let sessionID: String
  /// The time the activity started.
  public let startedAt: Date
  /// The time the activity ended.
  public let endedAt: Date

  /// Creates a `ChannelGuestStarSessionEndEvent` value.
  public init(
    broadcasterID: String,
    broadcasterDisplayName: String,
    broadcasterLogin: String,
    hostID: String,
    hostDisplayName: String,
    hostLogin: String,
    sessionID: String,
    startedAt: Date,
    endedAt: Date
  ) {
    self.broadcasterID = broadcasterID
    self.broadcasterDisplayName = broadcasterDisplayName
    self.broadcasterLogin = broadcasterLogin
    self.hostID = hostID
    self.hostDisplayName = hostDisplayName
    self.hostLogin = hostLogin
    self.sessionID = sessionID
    self.startedAt = startedAt
    self.endedAt = endedAt
  }

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterDisplayName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"
    case hostID = "hostUserId"
    case hostDisplayName = "hostUserName"
    case hostLogin = "hostUserLogin"
    case sessionID = "sessionId"
    case startedAt
    case endedAt
  }
}
