import Foundation

extension HelixEndpoint {
  /// Moves a guest between slots in a Guest Star session.
  ///
  /// With a user access token, requires `channel:manage:guest_star` or
  /// `moderator:manage:guest_star`. The moderator ID must match the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#update-guest-star-slot
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - sessionID: The identifier of the session.
  ///   - sourceSlotID: The source Guest Star slot ID.
  ///   - destinationSlotID: The destination Guest Star slot ID.
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  ///   - moderatorID: The moderator’s Twitch user ID; `nil` uses the executing client’s
  ///     authenticated user ID.
  public static func updateGuestStarSlot(
    sessionID: String,
    sourceSlotID: String,
    destinationSlotID: String? = nil,
    broadcasterID: String? = nil,
    moderatorID: String? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "PATCH", path: "guest_star/slot",
      authentication: .user,
      queryItems: { credentials in
        [
          (
            "broadcaster_id",
            try credentials.resolveUserID(broadcasterID, parameter: "broadcaster_id")
          ),
          (
            "moderator_id",
            try credentials.resolveUserID(moderatorID, parameter: "moderator_id")
          ),
          ("session_id", sessionID),
          ("source_slot_id", sourceSlotID),
          ("destination_slot_id", destinationSlotID),
        ]
      })
  }
}
