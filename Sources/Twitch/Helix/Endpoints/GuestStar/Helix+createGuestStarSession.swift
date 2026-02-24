import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == GuestStarSession,
  HelixResponseType == GuestStarSession
{
  public static func createGuestStarSession() -> Self {
    return .init(
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
