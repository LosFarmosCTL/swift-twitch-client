import Foundation

/// An EventSub notification delivered when a Guest Star session begins.
///
/// Uses Twitch’s beta Guest Star schema, which Twitch may change without notice.
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

  /// Creates a `ChannelGuestStarSessionBeginEvent` value.
  public init(
    broadcasterID: String,
    broadcasterDisplayName: String,
    broadcasterLogin: String,
    sessionID: String,
    startedAt: Date
  ) {
    self.broadcasterID = broadcasterID
    self.broadcasterDisplayName = broadcasterDisplayName
    self.broadcasterLogin = broadcasterLogin
    self.sessionID = sessionID
    self.startedAt = startedAt
  }

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterDisplayName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"
    case sessionID = "sessionId"
    case startedAt
  }
}
