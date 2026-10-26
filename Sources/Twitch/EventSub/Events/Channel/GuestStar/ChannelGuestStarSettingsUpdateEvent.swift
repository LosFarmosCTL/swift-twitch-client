import MemberwiseInit

/// An EventSub notification delivered when Guest Star settings change.
@MemberwiseInit(.public)
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

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterDisplayName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"
    case isModeratorSendLiveEnabled
    case isBrowserSourceAudioEnabled
    case slotCount
    case groupLayout
  }

  /// The arrangement and alignment of guests in the Guest Star browser source.
  public enum GroupLayout: String, Codable, Sendable {
    /// Arranges guests in tiles.
    case tiled
    /// Arranges guests around a shared screen.
    case screenshare
    /// Places the horizontal guest strip at the top. Encoded as `"horizontal_top"`.
    case horizontalTop = "horizontal_top"
    /// Places the horizontal guest strip at the bottom. Encoded as `"horizontal_bottom"`.
    case horizontalBottom = "horizontal_bottom"
    /// Places the vertical guest strip on the left. Encoded as `"vertical_left"`.
    case verticalLeft = "vertical_left"
    /// Places the vertical guest strip on the right. Encoded as `"vertical_right"`.
    case verticalRight = "vertical_right"
  }
}
