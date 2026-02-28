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
        guard let session = response.data.first else {
          throw HelixError.noDataInResponse(responseData: response.rawData)
        }

        return session
      })
  }
}
