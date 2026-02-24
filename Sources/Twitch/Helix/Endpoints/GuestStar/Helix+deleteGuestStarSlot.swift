import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func deleteGuestStarSlot(
    sessionID: String,
    guestID: String,
    slotID: String,
    shouldReinviteGuest: Bool? = nil,
    broadcasterID: String? = nil,
    moderatorID: String? = nil
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
