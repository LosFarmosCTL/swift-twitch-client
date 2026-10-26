import MemberwiseInit

/// An EventSub notification delivered when a held user message receives a moderation
/// decision.
@MemberwiseInit(.public)
public struct ChannelChatUserMessageUpdateEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  /// Whether the held chat message was approved, denied, or can no longer be updated.
  public let status: Status

  /// The identifier of the message.
  public let messageID: String
  /// The message content or explanatory text supplied by Twitch.
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

  /// The approval, denial, or invalidation of a held chat message.
  public enum Status: String, Decodable, Sendable {
    /// The held message was approved.
    case approved
    /// The held message was denied.
    case denied
    /// The held message can no longer be updated.
    case invalid
  }
}
