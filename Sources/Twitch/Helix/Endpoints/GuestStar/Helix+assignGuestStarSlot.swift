import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func assignGuestStarSlot(
    sessionID: String,
    guestID: UserID,
    slotID: String,
    broadcasterID: UserID? = nil,
    moderatorID: UserID? = nil
  ) -> Self {
    return .init(
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
