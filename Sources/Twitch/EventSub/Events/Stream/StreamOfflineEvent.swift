/// An EventSub notification delivered when a broadcaster stops streaming.
public struct StreamOfflineEvent: Event {
  /// The identifier of the stream that ended, when supplied by Twitch.
  public let id: String?
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// Creates a `StreamOfflineEvent` value.
  public init(
    id: String? = nil,
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String
  ) {
    self.id = id
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
  }

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
  }
}
