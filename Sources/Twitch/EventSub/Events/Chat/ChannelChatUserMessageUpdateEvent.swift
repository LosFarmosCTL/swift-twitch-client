import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelChatUserMessageUpdateEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let userID: String
  public let userLogin: String
  public let userDisplayName: String

  public let status: Status

  public let messageID: String
  public let message: AutoModMessage

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case messageID = "messageId"
    case message
    case status
  }

  public enum Status: String, Decodable, Sendable {
    case approved, denied, invalid
  }
}
