import Foundation

extension HelixEndpoint {
  public static func deleteGuestStarInvite(
    sessionID: String,
    guestID: String,
    broadcasterID: String? = nil,
    moderatorID: String? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
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
