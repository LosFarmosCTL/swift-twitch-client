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
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  public static func getUserBlocklist(
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<[BlockedUser], BlockedUser, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "users/blocks",
      queryItems: { credentials in
        [
          ("broadcaster_id", credentials.userID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      },
      makeResponse: {
        $0.data
      })
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
