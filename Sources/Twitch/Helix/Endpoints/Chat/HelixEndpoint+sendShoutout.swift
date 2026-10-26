import Foundation

extension HelixEndpoint {
  /// Sends a Shoutout from the authenticated broadcaster’s channel.
  ///
  /// With a user access token, requires `moderator:manage:shoutouts`. App tokens have
  /// additional grant requirements described in the reference. The moderator ID must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#send-a-shoutout
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `moderator_id`.
  ///
  /// - Parameters:
  ///   - fromBroadcasterID: The Twitch user ID of the source broadcaster.
  ///   - toBroadcasterID: The Twitch user ID of the destination broadcaster.
  public static func sendShoutout(
    from fromBroadcasterID: String,
    to toBroadcasterID: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "POST", path: "chat/shoutouts",
      queryItems: { credentials in
        [
          ("from_broadcaster_id", fromBroadcasterID),
          ("to_broadcaster_id", toBroadcasterID),
          ("moderator_id", credentials.userID),
        ]
      })
  }
}
