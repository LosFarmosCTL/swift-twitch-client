import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func updateGuestStarSlot(
    sessionID: String,
    sourceSlotID: String,
    destinationSlotID: String? = nil,
    broadcasterID: UserID? = nil,
    moderatorID: UserID? = nil
  ) -> Self {
    return .init(
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
