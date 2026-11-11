import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets the authenticated user’s blocked users.
  ///
  /// With a user access token, requires `user:read:blocked_users`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-user-block-list
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
  ) -> HelixEndpoint<
    (users: [BlockedUser], cursor: String?), BlockedUser, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "users/blocks",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", try credentials.requireUser().id),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ] + userIDs.map { ("user_id", $0) }
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

/// An account on the authenticated user’s block list.
@MemberwiseInit(.public)
public struct BlockedUser: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The display name shown on Twitch.
  public let displayName: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case displayName
  }
}
