import Foundation

extension HelixEndpoint {
  /// Removes a moderator from the authenticated broadcaster’s channel, or removes
  /// the authenticated moderator from another broadcaster’s channel.
  ///
  /// With a user access token, requires `channel:manage:moderators`.
  ///
  /// If the broadcaster differs from the token’s user, `userID` must match the token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/moderation/#remove-channel-moderator
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - userID: The Twitch user ID.
  ///   - broadcasterID: The target channel; `nil` uses the authenticated user’s channel.
  public static func removeChannelModerator(userID: String, broadcasterID: String? = nil)
    -> HelixEndpoint<Void>
  {
    .init(
      method: "DELETE", path: "moderation/moderators",
      authentication: .user,
      queryItems: { credentials in
        let actorID = try credentials.requireUser().id
        let channelID = try credentials.resolveUserID(broadcasterID, parameter: "broadcaster_id")
        guard channelID == actorID || userID == actorID else {
          throw TwitchAuthenticationError.userIDMismatch(parameter: "user_id")
        }
        return [
          ("broadcaster_id", channelID),
          ("user_id", userID),
        ]
      })
  }
}
