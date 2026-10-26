import Foundation

extension HelixEndpoint {
  /// Adds a term to a channel’s blocked terms.
  ///
  /// With a user access token, requires `moderator:manage:blocked_terms`. App tokens have
  /// additional grant requirements described in the reference. The moderator ID must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#add-blocked-term
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `moderator_id`.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - text: The text content.
  public static func addBlockedTerm(
    in broadcasterID: String,
    text: String
  ) -> HelixEndpoint<BlockedTerm, BlockedTerm, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "moderation/blocked_terms",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", credentials.userID),
        ]
      },
      body: { _ in ["text": text] },
      makeResponse: {
        let term = try $0.requireFirst()

        return term
      })
  }
}
