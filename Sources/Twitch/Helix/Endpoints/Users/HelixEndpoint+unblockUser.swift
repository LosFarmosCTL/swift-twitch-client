import Foundation

extension HelixEndpoint {
  /// Removes a user from the authenticated user’s block list.
  ///
  /// With a user access token, requires `user:manage:blocked_users`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#unblock-user
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - userID: The Twitch user ID.
  public static func unblockUser(_ userID: String)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    return .init(
      method: "DELETE", path: "users/blocks",
      authentication: .user,
      queryItems: { _ in [("target_user_id", userID)] })
  }
}
