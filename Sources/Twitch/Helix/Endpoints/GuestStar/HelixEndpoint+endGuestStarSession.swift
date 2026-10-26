import Foundation

extension HelixEndpoint {
  /// Ends the authenticated broadcaster’s Guest Star session.
  ///
  /// With a user access token, requires `channel:manage:guest_star`. The broadcaster ID
  /// must match the token’s user.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#end-guest-star-session
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - sessionID: The identifier of the session.
  public static func endGuestStarSession(
    sessionID: String
  ) -> HelixEndpoint<
    GuestStarSession, GuestStarSession,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "DELETE", path: "guest_star/session",
      queryItems: { credentials in
        [
          ("broadcaster_id", credentials.userID),
          ("session_id", sessionID),
        ]
      },
      makeResponse: { response in
        let session = try response.requireFirst()

        return session
      })
  }
}
