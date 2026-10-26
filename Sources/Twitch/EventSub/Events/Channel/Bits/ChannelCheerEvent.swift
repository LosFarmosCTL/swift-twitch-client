import MemberwiseInit

/// An EventSub notification delivered when a viewer cheers in a channel.
@MemberwiseInit(.public)
public struct ChannelCheerEvent: Event {
  /// Whether the user’s identity is anonymous.
  public let isAnonymous: Bool

  // null if anonymous
  /// The Twitch user ID, when provided.
  public let userID: String?
  /// The user’s login name, when provided.
  public let userLogin: String?
  /// The user’s display name, when provided.
  public let userDisplayName: String?

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The message content or explanatory text supplied by Twitch.
  public let message: String
  /// The number of Bits.
  public let bits: Int

  enum CodingKeys: String, CodingKey {
    case isAnonymous
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case message
    case bits
  }
}
