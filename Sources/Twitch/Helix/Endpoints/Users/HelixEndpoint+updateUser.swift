import Foundation

extension HelixEndpoint {
  /// Updates the authenticated user’s profile description.
  ///
  /// With a user access token, requires `user:edit`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#update-user
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - description: The profile description to set for the authenticated user.
  public static func updateUser(description: String)
    -> HelixEndpoint<User>
  {
    .init(
      method: "PUT", path: "users",
      authentication: .user,
      queryItems: { _ in
        [("description", description)]
      },
      responseType: User.self,
      makeResponse: {
        let user = try $0.requireFirst()

        return user
      })
  }
}
