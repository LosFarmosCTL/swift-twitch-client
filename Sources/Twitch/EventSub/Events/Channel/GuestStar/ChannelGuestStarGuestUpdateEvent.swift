import MemberwiseInit

/// An EventSub notification delivered when a Guest Star guest’s state changes.
@MemberwiseInit(.public)
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

  /// A guest’s progress from invitation through joining or leaving a Guest Star session.
  public enum State: String, Codable, Sendable {
    /// The guest has been invited but has not accepted.
    case invited
    /// The guest has accepted the invitation.
    case accepted
    /// The guest is ready to join the session.
    case ready
    /// The guest is backstage and is not live.
    case backstage
    /// The guest is live in the session.
    case live
    /// The guest was removed from the session.
    case removed
  }
}
