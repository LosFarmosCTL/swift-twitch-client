import Foundation

/// An EventSub notification delivered when a broadcaster starts streaming.
public struct StreamOnlineEvent: Event {
  /// The identifier assigned by Twitch.
  public let id: String

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The stream category, such as live, playlist, or watch party.
  public let type: StreamType
  /// The time the activity started.
  public let startedAt: Date

  /// Creates a `StreamOnlineEvent` value.
  public init(
    id: String,
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    type: StreamType,
    startedAt: Date
  ) {
    self.id = id
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.type = type
    self.startedAt = startedAt
  }

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case type
    case startedAt
  }

  /// The kind of broadcast that went online, preserving unfamiliar values in `rawValue`.
  public struct StreamType: RawRepresentable, Codable, Sendable, Hashable {
    /// The exact stream type string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates a stream type from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes a stream type from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// Encodes this stream type as its raw wire string.
    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(rawValue)
    }

    /// A live broadcast.
    public static let live = Self(rawValue: "live")
    /// A playlist broadcast.
    public static let playlist = Self(rawValue: "playlist")
    /// A premiere broadcast.
    public static let premiere = Self(rawValue: "premiere")
    /// A replayed broadcast.
    public static let rerun = Self(rawValue: "rerun")
    /// A Watch Party broadcast. Encoded as `"watch_party"`.
    public static let watchParty = Self(rawValue: "watch_party")
  }
}
