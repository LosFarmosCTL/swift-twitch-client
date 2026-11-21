/// An EventSub notification delivered when a user’s chat messages are cleared.
public struct ChannelChatClearUserMessagesEvent: Event {
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

  /// Creates a `ChannelChatClearUserMessagesEvent` value.
  public init(
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    targetID: String,
    targetLogin: String,
    targetDisplayName: String
  ) {
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.targetID = targetID
    self.targetLogin = targetLogin
    self.targetDisplayName = targetDisplayName
  }

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case targetID = "targetUserId"
    case targetLogin = "targetUserLogin"
    case targetDisplayName = "targetUserName"
  }
}
