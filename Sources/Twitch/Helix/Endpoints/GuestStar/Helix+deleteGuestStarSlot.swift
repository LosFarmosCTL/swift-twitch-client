import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func deleteGuestStarSlot(
    sessionID: String,
    guestID: UserID,
    slotID: String,
    shouldReinviteGuest: Bool? = nil,
    broadcasterID: UserID? = nil,
    moderatorID: UserID? = nil
  ) -> Self {
    return .init(
      method: "DELETE", path: "guest_star/slot",
      queryItems: { auth in
        [
          ("broadcaster_id", broadcasterID ?? auth.userID),
          ("moderator_id", moderatorID ?? auth.userID),
          ("session_id", sessionID),
          ("guest_id", guestID),
          ("slot_id", slotID),
          ("should_reinvite_guest", shouldReinviteGuest.map(String.init)),
        ]
      })
  }
}
