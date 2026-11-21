import Foundation

extension HelixEndpoint {
  /// Removes a user’s VIP status in the authenticated broadcaster’s channel.
  ///
  /// With a user access token, requires `channel:manage:vips`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/moderation/#remove-channel-vip
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - userID: The Twitch user ID.
  public static func removeChannelVIP(userID: String)
    -> HelixEndpoint<Void>
  {
    .init(
      method: "DELETE", path: "channels/vips",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", try credentials.requireUserID(parameter: "broadcaster_id")),
          ("user_id", userID),
        ]
      })
  }
}
