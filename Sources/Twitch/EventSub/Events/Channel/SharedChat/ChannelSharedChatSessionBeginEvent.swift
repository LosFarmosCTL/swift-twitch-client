/// An EventSub notification delivered when the subscribed channel becomes active in a
/// shared chat session, including when it joins a session already in progress.
public struct ChannelSharedChatSessionBeginEvent: Event {
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
  public let participants: [Participant]

  /// Creates a `ChannelSharedChatSessionBeginEvent` value.
  public init(
    sessionID: String,
    broadcasterID: String,
    broadcasterDisplayName: String,
    broadcasterLogin: String,
    hostBroadcasterID: String,
    hostBroadcasterDisplayName: String,
    hostBroadcasterLogin: String,
    participants: [Participant] = []
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

  /// The account identity of a channel participating in a shared chat session.
  public struct Participant: Decodable, Sendable {
    /// The Twitch user ID of the broadcaster.
    public let broadcasterID: String
    /// The display name of the broadcaster.
    public let broadcasterDisplayName: String
    /// The login name of the broadcaster.
    public let broadcasterLogin: String

    /// Creates a `Participant` value.
    public init(
      broadcasterID: String,
      broadcasterDisplayName: String,
      broadcasterLogin: String
    ) {
      self.broadcasterID = broadcasterID
      self.broadcasterDisplayName = broadcasterDisplayName
      self.broadcasterLogin = broadcasterLogin
    }

    enum CodingKeys: String, CodingKey {
      case broadcasterID = "broadcasterUserId"
      case broadcasterDisplayName = "broadcasterUserName"
      case broadcasterLogin = "broadcasterUserLogin"
    }
  }
}
