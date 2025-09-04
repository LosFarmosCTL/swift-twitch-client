public struct ChannelChatClearUserMessagesEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let targetID: String
  public let targetLogin: String
  public let targetName: String

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case targetID = "targetUserId"
    case targetLogin = "targetUserLogin"
    case targetName = "targetUserName"
  }
}
