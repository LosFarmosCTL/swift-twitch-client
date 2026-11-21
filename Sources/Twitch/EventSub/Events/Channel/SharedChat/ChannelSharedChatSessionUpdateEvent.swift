/// An EventSub notification delivered when a shared chat session’s participants change.
public struct ChannelSharedChatSessionUpdateEvent: Event {
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

  /// The broadcaster channels participating in the shared chat session.
  public let participants: [ChannelSharedChatSessionBeginEvent.Participant]

  /// Creates a `ChannelSharedChatSessionUpdateEvent` value.
  public init(
    sessionID: String,
    broadcasterID: String,
    broadcasterDisplayName: String,
    broadcasterLogin: String,
    hostBroadcasterID: String,
    hostBroadcasterDisplayName: String,
    hostBroadcasterLogin: String,
    participants: [ChannelSharedChatSessionBeginEvent.Participant] = []
  ) {
    self.sessionID = sessionID
    self.broadcasterID = broadcasterID
    self.broadcasterDisplayName = broadcasterDisplayName
    self.broadcasterLogin = broadcasterLogin
    self.hostBroadcasterID = hostBroadcasterID
    self.hostBroadcasterDisplayName = hostBroadcasterDisplayName
    self.hostBroadcasterLogin = hostBroadcasterLogin
    self.participants = participants
  }

  enum CodingKeys: String, CodingKey {
    case sessionID = "sessionId"
    case broadcasterID = "broadcasterUserId"
    case broadcasterDisplayName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"
    case hostBroadcasterID = "hostBroadcasterUserId"
    case hostBroadcasterDisplayName = "hostBroadcasterUserName"
    case hostBroadcasterLogin = "hostBroadcasterUserLogin"
    case participants
  }
}
