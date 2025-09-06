public struct ChannelSharedChatSessionEndEvent: Event {
  public let sessionID: String

  public let broadcasterID: String
  public let broadcasterName: String
  public let broadcasterLogin: String

  public let hostBroadcasterID: String
  public let hostBroadcasterName: String
  public let hostBroadcasterLogin: String

  enum CodingKeys: String, CodingKey {
    case sessionID = "sessionId"
    case broadcasterID = "broadcasterUserId"
    case broadcasterName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"
    case hostBroadcasterID = "hostBroadcasterUserId"
    case hostBroadcasterName = "hostBroadcasterUserName"
    case hostBroadcasterLogin = "hostBroadcasterUserLogin"
  }
}
