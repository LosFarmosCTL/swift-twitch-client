import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelSharedChatSessionBeginEvent: Event {
  public let sessionID: String

  public let broadcasterID: String
  public let broadcasterDisplayName: String
  public let broadcasterLogin: String

  public let hostBroadcasterID: String
  public let hostBroadcasterDisplayName: String
  public let hostBroadcasterLogin: String

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

  @MemberwiseInit(.public)
  public struct Participant: Decodable, Sendable {
    public let broadcasterID: String
    public let broadcasterDisplayName: String
    public let broadcasterLogin: String

    enum CodingKeys: String, CodingKey {
      case broadcasterID = "broadcasterUserId"
      case broadcasterDisplayName = "broadcasterUserName"
      case broadcasterLogin = "broadcasterUserLogin"
    }
  }
}
