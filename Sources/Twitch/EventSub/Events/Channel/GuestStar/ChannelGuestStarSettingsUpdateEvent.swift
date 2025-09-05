public struct ChannelGuestStarSettingsUpdateEvent: Event {
  public let broadcasterID: String
  public let broadcasterName: String
  public let broadcasterLogin: String

  public let isModeratorSendLiveEnabled: Bool
  public let isBrowserSourceAudioEnabled: Bool
  public let slotCount: Int
  public let groupLayout: GroupLayout

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"
    case isModeratorSendLiveEnabled, isBrowserSourceAudioEnabled, slotCount, groupLayout
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
