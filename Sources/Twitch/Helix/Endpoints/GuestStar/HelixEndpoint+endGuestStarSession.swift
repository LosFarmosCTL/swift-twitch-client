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
  /// https://dev.twitch.tv/docs/api/reference/guest-star/#end-guest-star-session
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - sessionID: The identifier of the session.
  public static func endGuestStarSession(
    sessionID: String
  ) -> HelixEndpoint<GuestStarSession> {
    .init(
      method: "DELETE", path: "guest_star/session",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", try credentials.requireUser().id),
          ("session_id", sessionID),
        ]
      },
      responseType: GuestStarSession.self,
      makeResponse: { response in
        let session = try response.requireFirst()

        return session
      })
  }
}
