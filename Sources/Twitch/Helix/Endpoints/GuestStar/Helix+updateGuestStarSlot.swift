import Foundation

extension HelixEndpoint {
  public static func updateGuestStarSlot(
    sessionID: String,
    sourceSlotID: String,
    destinationSlotID: String? = nil,
    broadcasterID: String? = nil,
    moderatorID: String? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "PATCH", path: "guest_star/slot",
      queryItems: { auth in
        [
          ("broadcaster_id", broadcasterID ?? auth.userID),
          ("moderator_id", moderatorID ?? auth.userID),
          ("session_id", sessionID),
          ("source_slot_id", sourceSlotID),
          ("destination_slot_id", destinationSlotID),
        ]
      })
  }
}
