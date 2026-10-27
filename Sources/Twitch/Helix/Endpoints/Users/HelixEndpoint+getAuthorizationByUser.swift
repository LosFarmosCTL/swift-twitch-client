import MemberwiseInit

extension HelixEndpoint {
  /// Gets the scopes that users have granted the calling application.
  ///
  /// Requires an app access token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-authorization-by-user
  /// ).
  ///
  /// - Parameter userIDs: The IDs of one through ten users to check.
  public static func getAuthorizationByUser(
    _ userIDs: [String]
  ) -> HelixEndpoint<
    [UserAuthorization], UserAuthorization, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "authorization/users",
      queryItems: { _ in userIDs.map { ("user_id", $0) } },
      makeResponse: { $0.data })
  }
}

/// A user’s authorization grants for the calling application.
@MemberwiseInit(.public)
public struct UserAuthorization: Decodable, Sendable {
  /// The user’s ID.
  public let userID: String
  /// The user’s display name.
  public let userDisplayName: String
  /// The user’s login name.
  public let userLogin: String
  /// Scopes the user has granted the application.
  public let scopes: [String]
  /// Whether the user has authorized the application.
  public let hasAuthorized: Bool

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userDisplayName = "userName"
    case userLogin, scopes, hasAuthorized
  }
}
