import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == GuestStarChannelSettings,
  HelixResponseType == GuestStarChannelSettings
{
  public static func getChannelGuestStarSettings(
    broadcasterID: String? = nil,
    moderatorID: String? = nil
  ) -> Self {
    return .init(
      method: "GET", path: "guest_star/channel_settings",
      queryItems: { auth in
        [
          ("broadcaster_id", broadcasterID ?? auth.userID),
          ("moderator_id", moderatorID ?? auth.userID),
        ]
      },
      makeResponse: { response in
        guard let settings = response.data.first else {
          throw HelixError.noDataInResponse(responseData: response.rawData)
        }

        return settings
      })
  }
}

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
