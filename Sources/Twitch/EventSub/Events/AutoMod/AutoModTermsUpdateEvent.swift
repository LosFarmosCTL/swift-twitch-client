/// An EventSub notification delivered when a channel’s AutoMod terms change.
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

  /// Creates an `AutoModTermsUpdateEvent` value.
  public init(
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    moderatorID: String,
    moderatorLogin: String,
    moderatorDisplayName: String,
    action: Action,
    fromAutoMod: Bool,
    terms: [String] = []
  ) {
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.moderatorID = moderatorID
    self.moderatorLogin = moderatorLogin
    self.moderatorDisplayName = moderatorDisplayName
    self.action = action
    self.fromAutoMod = fromAutoMod
    self.terms = terms
  }

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

  /// Whether terms were added to or removed from the blocked or permitted list,
  /// preserving unfamiliar values in `rawValue`.
  public struct Action: RawRepresentable, Decodable, Sendable, Hashable {
    /// The exact action string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates an action from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes an action from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// A term was added to the permitted list. Encoded as `"add_permitted"`.
    public static let addPermitted = Self(rawValue: "add_permitted")
    /// A term was added to the blocked list. Encoded as `"add_blocked"`.
    public static let addBlocked = Self(rawValue: "add_blocked")
    /// A term was removed from the permitted list. Encoded as `"remove_permitted"`.
    public static let removePermitted = Self(rawValue: "remove_permitted")
    /// A term was removed from the blocked list. Encoded as `"remove_blocked"`.
    public static let removeBlocked = Self(rawValue: "remove_blocked")
  }
}
