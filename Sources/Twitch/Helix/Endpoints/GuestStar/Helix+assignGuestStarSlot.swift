import Foundation

extension HelixEndpoint {
  public static func assignGuestStarSlot(
    sessionID: String,
    guestID: String,
    slotID: String,
    broadcasterID: String? = nil,
    moderatorID: String? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "POST", path: "guest_star/slot",
      queryItems: { auth in
        [
          ("broadcaster_id", broadcasterID ?? auth.userID),
          ("moderator_id", moderatorID ?? auth.userID),
          ("session_id", sessionID),
          ("guest_id", guestID),
          ("slot_id", slotID),
        ]
      })
  }
}
