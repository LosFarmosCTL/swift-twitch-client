import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == GuestStarSession,
  HelixResponseType == GuestStarSession
{
  public static func endGuestStarSession(sessionID: String) -> Self {
    return .init(
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
