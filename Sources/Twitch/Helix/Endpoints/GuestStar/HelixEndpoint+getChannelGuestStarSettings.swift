import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets a channel’s Guest Star configuration.
  ///
  /// With a user access token, requires `channel:read:guest_star` or
  /// `channel:manage:guest_star` or `moderator:read:guest_star` or
  /// `moderator:manage:guest_star`. The moderator ID must match the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-channel-guest-star-settings
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  ///   - moderatorID: The moderator’s Twitch user ID; `nil` uses the executing client’s
  ///     authenticated user ID.
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

/// A broadcaster’s Guest Star layout, slot, and moderator settings.
@MemberwiseInit(.public)
public struct GuestStarChannelSettings: Decodable, Sendable {
  /// Whether moderators can send guests live.
  public let isModeratorSendLiveEnabled: Bool
  /// The number of Guest Star slots.
  public let slotCount: Int
  /// Whether audio is enabled for the browser source.
  public let isBrowserSourceAudioEnabled: Bool
  /// The layout used to arrange Guest Star participants.
  public let groupLayout: GuestStarGroupLayout
  /// The token used to access Guest Star browser sources.
  public let browserSourceToken: String
}

/// Layouts used to arrange Guest Star participants in the browser source.
public enum GuestStarGroupLayout: String, Codable, Sendable {
  /// Arranges guests in a tiled layout. Encoded as `"TILED_LAYOUT"`.
  case tiledLayout = "TILED_LAYOUT"
  /// Arranges guests around a shared screen. Encoded as `"SCREENSHARE_LAYOUT"`.
  case screenshareLayout = "SCREENSHARE_LAYOUT"
  /// Arranges guests horizontally. Encoded as `"HORIZONTAL_LAYOUT"`.
  case horizontalLayout = "HORIZONTAL_LAYOUT"
  /// Arranges guests vertically. Encoded as `"VERTICAL_LAYOUT"`.
  case verticalLayout = "VERTICAL_LAYOUT"
}
