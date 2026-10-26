import Foundation

extension HelixEndpoint {
  /// Removes a user’s ban or timeout from a channel.
  ///
  /// With a user access token, requires `moderator:manage:banned_users`. App tokens have
  /// additional grant requirements described in the reference. The moderator ID must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#unban-user
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `moderator_id`.
  ///
  /// - Parameters:
  ///   - userID: The Twitch user ID.
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func unbanUser(
    _ userID: String,
    in broadcasterID: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "DELETE", path: "moderation/bans",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", credentials.userID),
          ("user_id", userID),
        ]
      })
  }
}
