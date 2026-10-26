import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelChatMessageDeleteEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let targetID: String
  public let targetLogin: String
  public let targetDisplayName: String

  public let messageID: String

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case targetID = "targetUserId"
    case targetLogin = "targetUserLogin"
    case targetDisplayName = "targetUserName"
    case messageID = "messageId"
  }
}
