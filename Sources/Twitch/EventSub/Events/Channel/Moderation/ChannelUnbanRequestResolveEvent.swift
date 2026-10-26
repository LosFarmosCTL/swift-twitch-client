import MemberwiseInit

/// An EventSub notification delivered when a moderator resolves an unban request.
@MemberwiseInit(.public)
public struct ChannelUnbanRequestResolveEvent: Event {
  /// The identifier assigned by Twitch.
  public let id: String

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The Twitch user ID of the moderator, when provided.
  public let moderatorID: String?
  /// The login name of the moderator, when provided.
  public let moderatorLogin: String?
  /// The display name of the moderator, when provided.
  public let moderatorDisplayName: String?

  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  /// The moderator’s explanation of the resolution, when provided.
  public let resolutionText: String?
  /// Whether the unban request was approved, denied, or canceled.
  public let status: RequestStatus

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case moderatorID = "moderatorId"
    case moderatorLogin
    case moderatorDisplayName = "moderatorName"
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case resolutionText
    case status
  }

  /// The approval, denial, or cancellation of an unban request.
  public enum RequestStatus: String, Codable, Sendable {
    /// The unban request was approved.
    case approved
    /// The unban request was denied.
    case denied
    /// The unban request was canceled. Encoded as `"canceled"`.
    case cancelled = "canceled"
  }
}
