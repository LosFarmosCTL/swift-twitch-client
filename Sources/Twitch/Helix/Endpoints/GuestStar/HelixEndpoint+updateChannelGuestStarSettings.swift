import Foundation

extension HelixEndpoint {
  /// Updates the authenticated broadcaster’s Guest Star configuration.
  ///
  /// With a user access token, requires `channel:manage:guest_star`. The broadcaster ID
  /// must match the token’s user.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#update-channel-guest-star-settings
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - isModeratorSendLiveEnabled: Whether moderators can send guests live, when
  ///     provided.
  ///   - slotCount: The number of Guest Star slots, when provided.
  ///   - isBrowserSourceAudioEnabled: Whether audio is enabled for the browser source,
  ///     when provided.
  ///   - groupLayout: The layout used to arrange Guest Star participants, when provided.
  ///   - regenerateBrowserSources: Whether to regenerate the browser source URLs.
  public static func updateChannelGuestStarSettings(
    isModeratorSendLiveEnabled: Bool? = nil,
    slotCount: Int? = nil,
    isBrowserSourceAudioEnabled: Bool? = nil,
    groupLayout: GuestStarGroupLayout? = nil,
    regenerateBrowserSources: Bool? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "PUT", path: "guest_star/channel_settings",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", try credentials.requireUser().id),
          (
            "is_moderator_send_live_enabled",
            isModeratorSendLiveEnabled.map(String.init)
          ),
          ("slot_count", slotCount.map(String.init)),
          (
            "is_browser_source_audio_enabled",
            isBrowserSourceAudioEnabled.map(String.init)
          ),
          ("group_layout", groupLayout?.rawValue),
          (
            "regenerate_browser_sources",
            regenerateBrowserSources.map(String.init)
          ),
        ]
      })
  }
}
