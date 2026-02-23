public struct ChannelSharedChatSessionBeginEvent: Event {
  public let sessionID: String

  public let broadcasterID: String
  public let broadcasterName: String
  public let broadcasterLogin: String

  public let hostBroadcasterID: String
  public let hostBroadcasterName: String
  public let hostBroadcasterLogin: String

  public let participants: [Participant]

  enum CodingKeys: String, CodingKey {
    case sessionID = "sessionId"

    case broadcasterID = "broadcasterUserId"
    case broadcasterName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"

    case hostBroadcasterID = "hostBroadcasterUserId"
    case hostBroadcasterName = "hostBroadcasterUserName"
    case hostBroadcasterLogin = "hostBroadcasterUserLogin"

    case participants
  }

  public struct Participant: Decodable, Sendable {
    public let broadcasterID: String
    public let broadcasterName: String
    public let broadcasterLogin: String

    enum CodingKeys: String, CodingKey {
      case broadcasterID = "broadcasterUserId"
      case broadcasterName = "broadcasterUserName"
      case broadcasterLogin = "broadcasterUserLogin"
    }
  }
}
