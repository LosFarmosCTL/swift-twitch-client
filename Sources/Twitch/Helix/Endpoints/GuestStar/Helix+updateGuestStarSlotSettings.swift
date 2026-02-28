import Foundation

extension HelixEndpoint {
  public static func updateGuestStarSlotSettings(
    sessionID: String,
    slotID: String,
    isAudioEnabled: Bool? = nil,
    isVideoEnabled: Bool? = nil,
    isLive: Bool? = nil,
    volume: Int? = nil,
    broadcasterID: String? = nil,
    moderatorID: String? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "PATCH", path: "guest_star/slot_settings",
      queryItems: { auth in
        [
          ("broadcaster_id", broadcasterID ?? auth.userID),
          ("moderator_id", moderatorID ?? auth.userID),
          ("session_id", sessionID),
          ("slot_id", slotID),
          ("is_audio_enabled", isAudioEnabled.map(String.init)),
          ("is_video_enabled", isVideoEnabled.map(String.init)),
          ("is_live", isLive.map(String.init)),
          ("volume", volume.map(String.init)),
        ]
      })
  }
}
