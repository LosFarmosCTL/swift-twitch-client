import MemberwiseInit

/// An EventSub notification delivered when a channel’s AutoMod terms change.
@MemberwiseInit(.public)
public struct AutoModTermsUpdateEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String
  /// The Twitch user ID of the moderator.
  public let moderatorID: String
  /// The login name of the moderator.
  public let moderatorLogin: String
  /// The display name of the moderator.
  public let moderatorDisplayName: String

  /// The action and any associated details.
  public let action: Action
  /// Whether AutoMod originated the action.
  public let fromAutoMod: Bool
  /// The AutoMod terms affected by the action.
  public let terms: [String]

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorDisplayName = "moderatorUserName"
    case action
    case fromAutoMod = "fromAutomod"
    case terms
  }

  /// Whether terms were added to or removed from the blocked or permitted list.
  public enum Action: String, Decodable, Sendable {
    /// A term was added to the permitted list. Encoded as `"add_permitted"`.
    case addPermitted = "add_permitted"
    /// A term was added to the blocked list. Encoded as `"add_blocked"`.
    case addBlocked = "add_blocked"
    /// A term was removed from the permitted list. Encoded as `"remove_permitted"`.
    case removePermitted = "remove_permitted"
    /// A term was removed from the blocked list. Encoded as `"remove_blocked"`.
    case removeBlocked = "remove_blocked"
  }
}
