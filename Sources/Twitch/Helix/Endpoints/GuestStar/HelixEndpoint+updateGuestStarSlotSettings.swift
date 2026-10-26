import Foundation

extension HelixEndpoint {
  /// Updates a Guest Star slot’s visibility, media, or volume settings.
  ///
  /// With a user access token, requires `channel:manage:guest_star` or
  /// `moderator:manage:guest_star`. The moderator ID must match the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#update-guest-star-slot-settings
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - sessionID: The identifier of the session.
  ///   - slotID: The identifier of the slot.
  ///   - isAudioEnabled: Whether audio is enabled, when provided.
  ///   - isVideoEnabled: Whether video is enabled, when provided.
  ///   - isLive: Whether the slot is visible and audible to viewers; `nil` leaves the
  ///     setting unchanged.
  ///   - volume: The audio volume setting, when provided.
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  ///   - moderatorID: The moderator’s Twitch user ID; `nil` uses the executing client’s
  ///     authenticated user ID.
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
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID ?? credentials.userID),
          ("moderator_id", moderatorID ?? credentials.userID),
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
