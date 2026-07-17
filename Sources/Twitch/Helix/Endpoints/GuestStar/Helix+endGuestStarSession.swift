import Foundation

extension HelixEndpoint {
  public static func endGuestStarSession(
    sessionID: String
  ) -> HelixEndpoint<
    GuestStarSession, GuestStarSession,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "DELETE", path: "guest_star/session",
      queryItems: { auth in
        [
          ("broadcaster_id", auth.userID),
          ("session_id", sessionID),
        ]
      },
      makeResponse: { response in
        let session = try response.requireFirst()

        return session
      })
  }
}
