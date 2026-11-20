import MemberwiseInit

/// An EventSub notification delivered when a broadcaster stops streaming.
@MemberwiseInit(.public)
public struct StreamOfflineEvent: Event {
  /// The identifier of the stream that ended, when supplied by Twitch.
  @Init(default: nil)
  public let id: String?
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
  }
}
