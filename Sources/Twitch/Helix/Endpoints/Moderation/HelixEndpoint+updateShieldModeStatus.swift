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
  /// Omit `moderatorID` to use the user token’s identity. App tokens require it explicitly.
  ///
  /// - Parameters:
  ///   - moderatorID: The acting user ID. Required with app tokens; otherwise defaults
  ///     to the user token’s identity.
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - isActive: Whether the resource is active.
  public static func updateShieldModeStatus(
    of broadcasterID: String,
    isActive: Bool,
    moderatorID: String? = nil
  ) -> HelixEndpoint<
    ShieldModeStatus, ShieldModeStatus,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "PUT", path: "moderation/shield_mode",
      authentication: .either,
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          (
            "moderator_id",
            try credentials.resolveUserID(
              moderatorID, parameter: "moderator_id", matchingToken: true)
          ),
        ]
      }, body: { _ in ["is_active": isActive] },
      makeResponse: {
        let status = try $0.requireFirst()
        return status
      })
  }
}
