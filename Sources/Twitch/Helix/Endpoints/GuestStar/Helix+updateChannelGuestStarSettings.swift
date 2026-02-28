import Foundation

extension HelixEndpoint {
  public static func updateChannelGuestStarSettings(
    isModeratorSendLiveEnabled: Bool? = nil,
    slotCount: Int? = nil,
    isBrowserSourceAudioEnabled: Bool? = nil,
    groupLayout: GuestStarGroupLayout? = nil,
    regenerateBrowserSources: Bool? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "PUT", path: "guest_star/channel_settings",
      queryItems: { auth in
        [
          ("broadcaster_id", auth.userID),
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
