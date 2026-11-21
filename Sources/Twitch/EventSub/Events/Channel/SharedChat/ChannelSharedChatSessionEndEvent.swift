/// An EventSub notification delivered when the subscribed channel leaves a shared chat
/// session or that session ends.
public struct ChannelSharedChatSessionEndEvent: Event {
  /// The identifier of the session.
  public let sessionID: String

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String

  /// The Twitch user ID of the host broadcaster.
  public let hostBroadcasterID: String
  /// The display name of the host broadcaster.
  public let hostBroadcasterDisplayName: String
  /// The login name of the host broadcaster.
  public let hostBroadcasterLogin: String

  /// Creates a `ChannelSharedChatSessionEndEvent` value.
  public init(
    sessionID: String,
    broadcasterID: String,
    broadcasterDisplayName: String,
    broadcasterLogin: String,
    hostBroadcasterID: String,
    hostBroadcasterDisplayName: String,
    hostBroadcasterLogin: String
  ) {
    self.sessionID = sessionID
    self.broadcasterID = broadcasterID
    self.broadcasterDisplayName = broadcasterDisplayName
    self.broadcasterLogin = broadcasterLogin
    self.hostBroadcasterID = hostBroadcasterID
    self.hostBroadcasterDisplayName = hostBroadcasterDisplayName
    self.hostBroadcasterLogin = hostBroadcasterLogin
  }

  enum CodingKeys: String, CodingKey {
    case sessionID = "sessionId"
    case broadcasterID = "broadcasterUserId"
    case broadcasterDisplayName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"
    case hostBroadcasterID = "hostBroadcasterUserId"
    case hostBroadcasterDisplayName = "hostBroadcasterUserName"
    case hostBroadcasterLogin = "hostBroadcasterUserLogin"
  }
}
