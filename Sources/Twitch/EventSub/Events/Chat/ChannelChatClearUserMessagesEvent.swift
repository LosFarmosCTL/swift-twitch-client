import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelChatClearUserMessagesEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let targetID: String
  public let targetLogin: String
  public let targetDisplayName: String

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case targetID = "targetUserId"
    case targetLogin = "targetUserLogin"
    case targetDisplayName = "targetUserName"
  }
}
