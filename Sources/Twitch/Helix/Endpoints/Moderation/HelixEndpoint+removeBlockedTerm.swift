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
  /// Omit `moderatorID` to use the user token’s identity. App tokens require it explicitly.
  ///
  /// - Parameters:
  ///   - moderatorID: The acting user ID. Required with app tokens; otherwise defaults
  ///     to the user token’s identity.
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - termID: The identifier of the term.
  public static func removeBlockedTerm(
    in broadcasterID: String, termID: String,
    moderatorID: String? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "DELETE", path: "moderation/blocked_terms",
      authentication: .either,
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          (
            "moderator_id",
            try credentials.resolveUserID(
              moderatorID, parameter: "moderator_id", matchingToken: true)
          ),
          ("id", termID),
        ]
      })
  }
}
