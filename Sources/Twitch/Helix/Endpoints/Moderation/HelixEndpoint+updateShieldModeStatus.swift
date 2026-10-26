import Foundation

extension HelixEndpoint {
  /// Enables or disables a channel’s Shield Mode.
  ///
  /// With a user access token, requires `moderator:manage:shield_mode`. App tokens have
  /// additional grant requirements described in the reference. The moderator ID must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#update-shield-mode-status
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `moderator_id`.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - isActive: Whether the resource is active.
  public static func updateShieldModeStatus(
    of broadcasterID: String,
    isActive: Bool
  ) -> HelixEndpoint<
    ShieldModeStatus, ShieldModeStatus,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "PUT", path: "moderation/shield_mode",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", credentials.userID),
        ]
      }, body: { _ in ["is_active": isActive] },
      makeResponse: {
        let status = try $0.requireFirst()
        return status
      })
  }
}
