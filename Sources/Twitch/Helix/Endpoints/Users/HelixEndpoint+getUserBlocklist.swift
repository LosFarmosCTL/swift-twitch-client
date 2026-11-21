import Foundation

extension HelixEndpoint {
  /// Gets the authenticated user’s blocked users.
  ///
  /// With a user access token, requires `user:read:blocked_users` or `user:manage:blocked_users`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/users/#get-user-block-list
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - userIDs: Specific users to check against the block list. Defaults to `[]`.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - cursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  public static func getUserBlocklist(
    userIDs: [String] = [],
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<UserBlocklistResponse> {
    .init(
      method: "GET", path: "users/blocks",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", try credentials.requireUserID(parameter: "broadcaster_id")),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ] + userIDs.map { ("user_id", $0) }
      },
      responseType: BlockedUser.self,
      makeResponse: { UserBlocklistResponse(users: $0.data, cursor: $0.pagination?.cursor) })
  }
}

/// A page of users blocked by the broadcaster.
public struct UserBlocklistResponse: Sendable {
  /// The users on this page.
  public let users: [BlockedUser]
  /// The cursor for the next page, if Twitch returned one.
  public let cursor: String?

  /// Creates a `UserBlocklistResponse` value.
  public init(
    users: [BlockedUser] = [],
    cursor: String? = nil
  ) {
    self.users = users
    self.cursor = cursor
  }
}

/// An account on the authenticated user’s block list.
public struct BlockedUser: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The display name shown on Twitch.
  public let displayName: String

  /// Creates a `BlockedUser` value.
  public init(
    userID: String,
    userLogin: String,
    displayName: String
  ) {
    self.userID = userID
    self.userLogin = userLogin
    self.displayName = displayName
  }

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case displayName
  }
}
