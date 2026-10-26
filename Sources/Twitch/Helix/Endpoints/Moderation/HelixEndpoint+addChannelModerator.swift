import Foundation

extension HelixEndpoint {
  /// Grants a user the moderator role in the authenticated broadcaster’s channel.
  ///
  /// With a user access token, requires `channel:manage:moderators`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#add-channel-moderator
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - userID: The Twitch user ID.
  public static func addChannelModerator(userID: String)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    .init(
      method: "POST", path: "moderation/moderators",
      queryItems: { credentials in
        [
          ("broadcaster_id", credentials.userID),
          ("user_id", userID),
        ]
      })
  }
}
