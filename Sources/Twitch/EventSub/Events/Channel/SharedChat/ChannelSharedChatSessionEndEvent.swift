import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelSharedChatSessionEndEvent: Event {
  public let sessionID: String

  public let broadcasterID: String
  public let broadcasterDisplayName: String
  public let broadcasterLogin: String

  public let hostBroadcasterID: String
  public let hostBroadcasterDisplayName: String
  public let hostBroadcasterLogin: String

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
