extension HelixEndpoint {
  /// Approves or denies an unban request.
  ///
  /// Requires a user token with `moderator:manage:unban_requests`. The moderator ID must
  /// match the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/moderation/#resolve-unban-requests
  /// ).
  ///
  /// - Parameters:
  ///   - requestID: The unban request to resolve.
  ///   - broadcasterID: The channel broadcaster’s ID.
  ///   - status: Whether to approve or deny the request.
  ///   - resolutionText: An optional explanation, at most 500 characters.
  public static func resolveUnbanRequest(
    _ requestID: String, in broadcasterID: String, status: UnbanRequestResolution,
    resolutionText: String? = nil
  ) -> HelixEndpoint<UnbanRequest> {
    .init(
      method: "PATCH", path: "moderation/unban_requests",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", try credentials.requireUserID(parameter: "moderator_id")),
          ("unban_request_id", requestID), ("status", status.rawValue),
          ("resolution_text", resolutionText),
        ]
      }, responseType: UnbanRequest.self, makeResponse: { try $0.requireFirst() })
  }
}

/// The decisions a moderator can apply to an unban request.
public enum UnbanRequestResolution: String, Sendable {
  /// Approves the request.
  case approved
  /// Denies the request.
  case denied
}
