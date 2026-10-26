import MemberwiseInit

/// An EventSub notification delivered when a chat message is deleted.
@MemberwiseInit(.public)
public struct ChannelChatMessageDeleteEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The Twitch user ID of the target user.
  public let targetID: String
  /// The login name of the target user.
  public let targetLogin: String
  /// The display name of the target user.
  public let targetDisplayName: String

  /// The identifier of the message.
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
