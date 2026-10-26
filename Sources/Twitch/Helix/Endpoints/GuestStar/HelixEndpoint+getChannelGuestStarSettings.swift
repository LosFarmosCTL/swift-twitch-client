import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getChannelGuestStarSettings(
    broadcasterID: String? = nil,
    moderatorID: String? = nil
  ) -> HelixEndpoint<
    GuestStarChannelSettings, GuestStarChannelSettings,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "guest_star/channel_settings",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID ?? credentials.userID),
          ("moderator_id", moderatorID ?? credentials.userID),
        ]
      },
      makeResponse: { response in
        let settings = try response.requireFirst()

        return settings
      })
  }
}

@MemberwiseInit(.public)
public struct GuestStarChannelSettings: Decodable, Sendable {
  public let isModeratorSendLiveEnabled: Bool
  public let slotCount: Int
  public let isBrowserSourceAudioEnabled: Bool
  public let groupLayout: GuestStarGroupLayout
  public let browserSourceToken: String
}

public enum GuestStarGroupLayout: String, Codable, Sendable {
  case tiledLayout = "TILED_LAYOUT"
  case screenshareLayout = "SCREENSHARE_LAYOUT"
  case horizontalLayout = "HORIZONTAL_LAYOUT"
  case verticalLayout = "VERTICAL_LAYOUT"
}
