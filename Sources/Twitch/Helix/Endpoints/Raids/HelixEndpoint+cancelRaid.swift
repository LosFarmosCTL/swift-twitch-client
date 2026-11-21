import Foundation

extension HelixEndpoint {
  /// Cancels a raid.
  ///
  /// With a user access token, requires `channel:manage:raids`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/raids/#cancel-a-raid
  /// ) for request limits and account requirements.
  public static func cancelRaid()
    -> HelixEndpoint<Void>
  {
    .init(
      method: "DELETE", path: "raids",
      authentication: .user,
      queryItems: { credentials in
        [("broadcaster_id", try credentials.requireUserID(parameter: "broadcaster_id"))]
      })
  }
}
