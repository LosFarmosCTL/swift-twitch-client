/// An EventSub notification delivered when a moderator resolves an unban request.
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

  /// Creates a `ChannelUnbanRequestResolveEvent` value.
  public init(
    id: String,
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    moderatorID: String? = nil,
    moderatorLogin: String? = nil,
    moderatorDisplayName: String? = nil,
    userID: String,
    userLogin: String,
    userDisplayName: String,
    resolutionText: String? = nil,
    status: RequestStatus
  ) {
    self.id = id
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.moderatorID = moderatorID
    self.moderatorLogin = moderatorLogin
    self.moderatorDisplayName = moderatorDisplayName
    self.userID = userID
    self.userLogin = userLogin
    self.userDisplayName = userDisplayName
    self.resolutionText = resolutionText
    self.status = status
  }

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorDisplayName = "moderatorUserName"
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case resolutionText
    case status
  }

  /// The approval, denial, or cancellation of an unban request, preserving unfamiliar
  /// values in `rawValue`.
  public struct RequestStatus: RawRepresentable, Codable, Sendable, Hashable {
    /// The exact status string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates a request status from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes a request status from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// Encodes this request status as its raw wire string.
    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(rawValue)
    }

    /// The unban request was approved.
    public static let approved = Self(rawValue: "approved")
    /// The unban request was denied.
    public static let denied = Self(rawValue: "denied")
    /// The unban request was canceled. Encoded as `"canceled"`.
    public static let cancelled = Self(rawValue: "canceled")
  }
}
