import Foundation

extension HelixEndpoint {
  /// Removes a term from a channel’s blocked terms.
  ///
  /// With a user access token, requires `moderator:manage:blocked_terms`. App tokens have
  /// additional grant requirements described in the reference. The moderator ID must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#remove-blocked-term
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `moderator_id`.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - termID: The identifier of the term.
  public static func removeBlockedTerm(
    in broadcasterID: String, termID: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "DELETE", path: "moderation/blocked_terms",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", credentials.userID),
          ("id", termID),
        ]
      })
  }
}
