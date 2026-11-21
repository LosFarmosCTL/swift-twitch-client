import Foundation

extension HelixEndpoint {
  /// Gets a channel’s Guest Star configuration.
  ///
  /// With a user access token, requires `channel:read:guest_star` or
  /// `channel:manage:guest_star` or `moderator:read:guest_star` or
  /// `moderator:manage:guest_star`. The moderator ID must match the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/guest-star/#get-channel-guest-star-settings
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  public static func getChannelGuestStarSettings(
    broadcasterID: String? = nil
  ) -> HelixEndpoint<GuestStarChannelSettings> {
    .init(
      method: "GET", path: "guest_star/channel_settings",
      authentication: .user,
      queryItems: { credentials in
        [
          (
            "broadcaster_id",
            try credentials.resolveUserID(broadcasterID, parameter: "broadcaster_id")
          ),
          ("moderator_id", try credentials.requireUser().id),
        ]
      },
      responseType: GuestStarChannelSettings.self,
      makeResponse: { response in
        let settings = try response.requireFirst()

        return settings
      })
  }
}

/// A broadcaster’s Guest Star layout, slot, and moderator settings.
public struct GuestStarChannelSettings: Decodable, Sendable {
  /// Whether moderators can send guests live.
  public let isModeratorSendLiveEnabled: Bool
  /// The number of Guest Star slots.
  public let slotCount: Int
  /// Whether audio is enabled for the browser source.
  public let isBrowserSourceAudioEnabled: Bool
  /// The layout used to arrange Guest Star participants.
  public let groupLayout: GuestStarGroupLayout
  /// The browser source token; `nil` when the requester is not the broadcaster.
  public let browserSourceToken: String?

  /// Creates a `GuestStarChannelSettings` value.
  public init(
    isModeratorSendLiveEnabled: Bool,
    slotCount: Int,
    isBrowserSourceAudioEnabled: Bool,
    groupLayout: GuestStarGroupLayout,
    browserSourceToken: String? = nil
  ) {
    self.isModeratorSendLiveEnabled = isModeratorSendLiveEnabled
    self.slotCount = slotCount
    self.isBrowserSourceAudioEnabled = isBrowserSourceAudioEnabled
    self.groupLayout = groupLayout
    self.browserSourceToken = browserSourceToken
  }
}

/// Layouts used to arrange Guest Star participants in the browser source, preserving
/// unfamiliar values in `rawValue`.
public struct GuestStarGroupLayout: RawRepresentable, Codable, Sendable, Hashable {
  /// The exact group layout string supplied by Twitch or the caller.
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

  /// Arranges guests in a tiled layout. Encoded as `"TILED"`.
  public static let tiledLayout = Self(rawValue: "TILED")
  /// Arranges guests around a shared screen. Encoded as `"SCREENSHARE"`.
  public static let screenshareLayout = Self(rawValue: "SCREENSHARE")
  /// Arranges guests in a horizontal strip. Encoded as `"HORIZONTAL_LAYOUT"`.
  public static let horizontalLayout = Self(rawValue: "HORIZONTAL_LAYOUT")
  /// Arranges guests in a vertical strip. Encoded as `"VERTICAL_LAYOUT"`.
  public static let verticalLayout = Self(rawValue: "VERTICAL_LAYOUT")
}
