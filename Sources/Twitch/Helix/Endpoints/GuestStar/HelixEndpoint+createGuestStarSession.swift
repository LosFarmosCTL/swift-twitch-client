import Foundation

extension HelixEndpoint {
  public static func createGuestStarSession() -> HelixEndpoint<
    GuestStarSession, GuestStarSession, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "POST", path: "guest_star/session",
      queryItems: { credentials in
        [("broadcaster_id", credentials.userID)]
      },
      makeResponse: { response in
        let session = try response.requireFirst()

        return session
      })
  }
}
