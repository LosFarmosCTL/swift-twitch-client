import Foundation

extension HelixEndpoint {
  /// Cancels a raid.
  ///
  /// With a user access token, requires `channel:manage:raids`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#cancel-a-raid
  /// ) for request limits and account requirements.
  public static func cancelRaid()
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    .init(
      method: "DELETE", path: "raids",
      queryItems: { credentials in
        [("broadcaster_id", credentials.userID)]
      })
  }
}
