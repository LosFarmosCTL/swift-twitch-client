public struct ChannelChatUserMessageUpdateEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let userID: String
  public let userLogin: String
  public let userName: String

  public let status: Status

  public let messageID: String
  public let message: AutomodMessage

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"
    case userID = "userId"
    case userLogin = "userLogin"
    case userName = "userName"

    case messageID = "messageId"
    case message, status
  }

  public enum Status: String, Decodable, Sendable {
    case approved, denied, expired
  }
}
