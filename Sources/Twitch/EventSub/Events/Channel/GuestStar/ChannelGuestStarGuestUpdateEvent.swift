/// An EventSub notification delivered when a Guest Star guest’s state changes.
///
/// Uses Twitch’s beta Guest Star schema, which Twitch may change without notice.
public struct ChannelGuestStarGuestUpdateEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String

  /// The Twitch user ID of the moderator, when provided.
  public let moderatorID: String?
  /// The display name of the moderator, when provided.
  public let moderatorDisplayName: String?
  /// The login name of the moderator, when provided.
  public let moderatorLogin: String?

  /// The Twitch user ID of the guest, when provided.
  public let guestID: String?
  /// The display name of the guest, when provided.
  public let guestDisplayName: String?
  /// The login name of the guest, when provided.
  public let guestLogin: String?

  /// The Twitch user ID of the host.
  public let hostID: String
  /// The display name of the host.
  public let hostDisplayName: String
  /// The login name of the host.
  public let hostLogin: String

  /// The identifier of the session.
  public let sessionID: String
  /// The identifier of the slot, when provided.
  public let slotID: String?
  /// The current state, when provided.
  public let state: State?

  /// Whether host video is enabled, when provided.
  public let hostVideoEnabled: Bool?
  /// Whether host audio is enabled, when provided.
  public let hostAudioEnabled: Bool?
  /// The guest’s audio volume for the host, when provided.
  public let hostVolume: Int?

  /// Creates a `ChannelGuestStarGuestUpdateEvent` value.
  public init(
    broadcasterID: String,
    broadcasterDisplayName: String,
    broadcasterLogin: String,
    moderatorID: String? = nil,
    moderatorDisplayName: String? = nil,
    moderatorLogin: String? = nil,
    guestID: String? = nil,
    guestDisplayName: String? = nil,
    guestLogin: String? = nil,
    hostID: String,
    hostDisplayName: String,
    hostLogin: String,
    sessionID: String,
    slotID: String? = nil,
    state: State? = nil,
    hostVideoEnabled: Bool? = nil,
    hostAudioEnabled: Bool? = nil,
    hostVolume: Int? = nil
  ) {
    self.broadcasterID = broadcasterID
    self.broadcasterDisplayName = broadcasterDisplayName
    self.broadcasterLogin = broadcasterLogin
    self.moderatorID = moderatorID
    self.moderatorDisplayName = moderatorDisplayName
    self.moderatorLogin = moderatorLogin
    self.guestID = guestID
    self.guestDisplayName = guestDisplayName
    self.guestLogin = guestLogin
    self.hostID = hostID
    self.hostDisplayName = hostDisplayName
    self.hostLogin = hostLogin
    self.sessionID = sessionID
    self.slotID = slotID
    self.state = state
    self.hostVideoEnabled = hostVideoEnabled
    self.hostAudioEnabled = hostAudioEnabled
    self.hostVolume = hostVolume
  }

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterDisplayName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"
    case moderatorID = "moderatorUserId"
    case moderatorDisplayName = "moderatorUserName"
    case moderatorLogin = "moderatorUserLogin"
    case guestID = "guestUserId"
    case guestDisplayName = "guestUserName"
    case guestLogin = "guestUserLogin"
    case hostID = "hostUserId"
    case hostDisplayName = "hostUserName"
    case hostLogin = "hostUserLogin"
    case sessionID = "sessionId"
    case slotID = "slotId"
    case state
    case hostVideoEnabled
    case hostAudioEnabled
    case hostVolume
  }

  /// A guest’s progress from invitation through joining or leaving a Guest Star session,
  /// preserving unfamiliar values in `rawValue`.
  public struct State: RawRepresentable, Codable, Sendable, Hashable {
    /// The exact state string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates a guest state from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes a guest state from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// Encodes this guest state as its raw wire string.
    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(rawValue)
    }

    /// The guest has been invited but has not accepted.
    public static let invited = Self(rawValue: "invited")
    /// The guest has accepted the invitation.
    public static let accepted = Self(rawValue: "accepted")
    /// The guest is ready to join the session.
    public static let ready = Self(rawValue: "ready")
    /// The guest is backstage and is not live.
    public static let backstage = Self(rawValue: "backstage")
    /// The guest is live in the session.
    public static let live = Self(rawValue: "live")
    /// The guest was removed from the session.
    public static let removed = Self(rawValue: "removed")
  }
}
