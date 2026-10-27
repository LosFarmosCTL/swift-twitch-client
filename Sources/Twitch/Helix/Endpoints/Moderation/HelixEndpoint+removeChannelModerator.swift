import Foundation

extension HelixEndpoint {
  /// Removes a user’s moderator role in the authenticated broadcaster’s channel.
  ///
  /// With a user access token, requires `channel:manage:moderators`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#remove-channel-moderator
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - userID: The Twitch user ID.
  public static func removeChannelModerator(userID: String)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    .init(
      method: "DELETE", path: "moderation/moderators",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", try credentials.requireUser().id),
          ("user_id", userID),
        ]
      })
  }
}
