import MemberwiseInit

/// An EventSub notification delivered when the subscribed channel becomes active in a
/// shared chat session, including when it joins a session already in progress.
@MemberwiseInit(.public)
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
  @MemberwiseInit(.public)
  public struct Participant: Decodable, Sendable {
    /// The Twitch user ID of the broadcaster.
    public let broadcasterID: String
    /// The display name of the broadcaster.
    public let broadcasterDisplayName: String
    /// The login name of the broadcaster.
    public let broadcasterLogin: String

    enum CodingKeys: String, CodingKey {
      case broadcasterID = "broadcasterUserId"
      case broadcasterDisplayName = "broadcasterUserName"
      case broadcasterLogin = "broadcasterUserLogin"
    }
  }
}
