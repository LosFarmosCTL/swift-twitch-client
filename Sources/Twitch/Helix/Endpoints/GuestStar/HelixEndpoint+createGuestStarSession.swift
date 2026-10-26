import Foundation

extension HelixEndpoint {
  /// Starts a Guest Star session for the authenticated broadcaster.
  ///
  /// With a user access token, requires `channel:manage:guest_star`. The broadcaster ID
  /// must match the token’s user.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#create-guest-star-session
  /// ) for request limits and account requirements.
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
