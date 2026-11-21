/// An EventSub notification delivered when Guest Star settings change.
///
/// Uses Twitch’s beta Guest Star schema, which Twitch may change without notice.
public struct ChannelGuestStarSettingsUpdateEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String

  /// Whether moderators can send guests live.
  public let isModeratorSendLiveEnabled: Bool
  /// Whether audio is enabled for the browser source.
  public let isBrowserSourceAudioEnabled: Bool
  /// The number of Guest Star slots.
  public let slotCount: Int
  /// The layout used to arrange Guest Star participants.
  public let groupLayout: GroupLayout

  /// Creates a `ChannelGuestStarSettingsUpdateEvent` value.
  public init(
    broadcasterID: String,
    broadcasterDisplayName: String,
    broadcasterLogin: String,
    isModeratorSendLiveEnabled: Bool,
    isBrowserSourceAudioEnabled: Bool,
    slotCount: Int,
    groupLayout: GroupLayout
  ) {
    self.broadcasterID = broadcasterID
    self.broadcasterDisplayName = broadcasterDisplayName
    self.broadcasterLogin = broadcasterLogin
    self.isModeratorSendLiveEnabled = isModeratorSendLiveEnabled
    self.isBrowserSourceAudioEnabled = isBrowserSourceAudioEnabled
    self.slotCount = slotCount
    self.groupLayout = groupLayout
  }

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterDisplayName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"
    case isModeratorSendLiveEnabled
    case isBrowserSourceAudioEnabled
    case slotCount
    case groupLayout
  }

  /// The arrangement and alignment of guests in the Guest Star browser source,
  /// preserving unfamiliar values in `rawValue`.
  public struct GroupLayout: RawRepresentable, Codable, Sendable, Hashable {
    /// The exact layout string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates a group layout from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes a group layout from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// Encodes this group layout as its raw wire string.
    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(rawValue)
    }

    /// Arranges guests in tiles.
    public static let tiled = Self(rawValue: "tiled")
    /// Arranges guests around a shared screen.
    public static let screenshare = Self(rawValue: "screenshare")
    /// Places the horizontal guest strip at the top. Encoded as `"horizontal_top"`.
    public static let horizontalTop = Self(rawValue: "horizontal_top")
    /// Places the horizontal guest strip at the bottom. Encoded as `"horizontal_bottom"`.
    public static let horizontalBottom = Self(rawValue: "horizontal_bottom")
    /// Places the vertical guest strip on the left. Encoded as `"vertical_left"`.
    public static let verticalLeft = Self(rawValue: "vertical_left")
    /// Places the vertical guest strip on the right. Encoded as `"vertical_right"`.
    public static let verticalRight = Self(rawValue: "vertical_right")
  }
}
