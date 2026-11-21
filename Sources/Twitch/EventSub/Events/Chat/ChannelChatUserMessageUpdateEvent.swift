/// An EventSub notification delivered when a held user message receives a moderation
/// decision.
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

  /// Creates a `ChannelChatUserMessageUpdateEvent` value.
  public init(
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    userID: String,
    userLogin: String,
    userDisplayName: String,
    status: Status,
    messageID: String,
    message: AutoModMessage
  ) {
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.userID = userID
    self.userLogin = userLogin
    self.userDisplayName = userDisplayName
    self.status = status
    self.messageID = messageID
    self.message = message
  }

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

  /// The approval, denial, or invalidation of a held chat message, preserving unfamiliar
  /// values in `rawValue`.
  public struct Status: RawRepresentable, Decodable, Sendable, Hashable {
    /// The exact status string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates a status from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes a status from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// The held message was approved.
    public static let approved = Self(rawValue: "approved")
    /// The held message was denied.
    public static let denied = Self(rawValue: "denied")
    /// The held message can no longer be updated.
    public static let invalid = Self(rawValue: "invalid")
  }
}
