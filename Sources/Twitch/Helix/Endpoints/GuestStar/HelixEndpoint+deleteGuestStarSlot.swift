import Foundation

extension HelixEndpoint {
  public static func deleteGuestStarSlot(
    sessionID: String,
    guestID: String,
    slotID: String,
    shouldReinviteGuest: Bool? = nil,
    broadcasterID: String? = nil,
    moderatorID: String? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "DELETE", path: "guest_star/slot",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID ?? credentials.userID),
          ("moderator_id", moderatorID ?? credentials.userID),
          ("session_id", sessionID),
          ("guest_id", guestID),
          ("slot_id", slotID),
          ("should_reinvite_guest", shouldReinviteGuest.map(String.init)),
        ]
      })
  }
}
