import Foundation

extension HelixEndpoint {
  public static func createGuestStarSession() -> HelixEndpoint<
    GuestStarSession, GuestStarSession, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "POST", path: "guest_star/session",
      queryItems: { auth in
        [("broadcaster_id", auth.userID)]
      },
      makeResponse: { response in
        let session = try response.requireFirst()

        return session
      })
  }
}
