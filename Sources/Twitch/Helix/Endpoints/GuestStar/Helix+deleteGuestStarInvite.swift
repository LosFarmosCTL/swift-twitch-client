import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func deleteGuestStarInvite(
    sessionID: String,
    guestID: UserID,
    broadcasterID: UserID? = nil,
    moderatorID: UserID? = nil
  ) -> Self {
    return .init(
      method: "DELETE", path: "guest_star/invites",
      queryItems: { auth in
        [
          ("broadcaster_id", broadcasterID ?? auth.userID),
          ("moderator_id", moderatorID ?? auth.userID),
          ("session_id", sessionID),
          ("guest_id", guestID),
        ]
      })
  }
}
