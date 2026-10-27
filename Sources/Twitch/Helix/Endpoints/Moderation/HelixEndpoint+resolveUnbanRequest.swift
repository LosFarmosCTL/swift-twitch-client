extension HelixEndpoint {
  /// Approves or denies an unban request.
  ///
  /// Requires a user token with `moderator:manage:unban_requests`. The moderator ID must
  /// match the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#resolve-unban-requests
  /// ).
  ///
  /// - Parameters:
  ///   - requestID: The unban request to resolve.
  ///   - broadcasterID: The channel broadcaster’s ID.
  ///   - status: Whether to approve or deny the request.
  ///   - resolutionText: An optional explanation, at most 500 characters.
  ///   - moderatorID: The acting moderator’s ID; `nil` uses the user token’s identity.
  ///     Required for app tokens.
  public static func resolveUnbanRequest(
    _ requestID: String, in broadcasterID: String, status: UnbanRequestResolution,
    resolutionText: String? = nil, moderatorID: String? = nil
  ) -> HelixEndpoint<UnbanRequest, UnbanRequest, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "PATCH", path: "moderation/unban_requests",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          (
            "moderator_id",
            try credentials.resolveUserID(
              moderatorID, parameter: "moderator_id", matchingToken: true)
          ),
          ("unban_request_id", requestID), ("status", status.rawValue),
          ("resolution_text", resolutionText),
        ]
      }, makeResponse: { try $0.requireFirst() })
  }
}

/// The decisions a moderator can apply to an unban request.
public enum UnbanRequestResolution: String, Sendable {
  /// Approves the request.
  case approved
  /// Denies the request.
  case denied
}
