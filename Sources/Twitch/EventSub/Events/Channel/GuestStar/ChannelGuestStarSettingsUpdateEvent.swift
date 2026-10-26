import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelGuestStarSettingsUpdateEvent: Event {
  public let broadcasterID: String
  public let broadcasterDisplayName: String
  public let broadcasterLogin: String

  public let isModeratorSendLiveEnabled: Bool
  public let isBrowserSourceAudioEnabled: Bool
  public let slotCount: Int
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

  public enum GroupLayout: String, Codable, Sendable {
    case tiled
    case screenshare
    case horizontalTop = "horizontal_top"
    case horizontalBottom = "horizontal_bottom"
    case verticalLeft = "vertical_left"
    case verticalRight = "vertical_right"
  }
}
