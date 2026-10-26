import Foundation

extension HelixEndpoint {
  /// Assigns a guest to a slot in a Guest Star session.
  ///
  /// With a user access token, requires `channel:manage:guest_star` or
  /// `moderator:manage:guest_star`. The moderator ID must match the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#assign-guest-star-slot
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - sessionID: The identifier of the session.
  ///   - guestID: The Twitch user ID of the guest.
  ///   - slotID: The identifier of the slot.
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  ///   - moderatorID: The moderator’s Twitch user ID; `nil` uses the executing client’s
  ///     authenticated user ID.
  public static func assignGuestStarSlot(
    sessionID: String,
    guestID: String,
    slotID: String,
    broadcasterID: String? = nil,
    moderatorID: String? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "POST", path: "guest_star/slot",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID ?? credentials.userID),
          ("moderator_id", moderatorID ?? credentials.userID),
          ("session_id", sessionID),
          ("guest_id", guestID),
          ("slot_id", slotID),
        ]
      })
  }
}
