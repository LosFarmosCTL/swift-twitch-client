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
        guard let session = response.data.first else {
          throw HelixError.noDataInResponse(responseData: response.rawData)
        }

        return session
      })
  }
}
