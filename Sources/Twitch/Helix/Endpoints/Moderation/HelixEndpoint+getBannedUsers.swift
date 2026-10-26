import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets users banned or timed out from the authenticated broadcaster’s channel.
  ///
  /// With a user access token, requires `moderation:read` or
  /// `moderator:manage:banned_users`. App tokens have additional grant requirements
  /// described in the reference.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-banned-users
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - userIDs: The user IDs to include in the request. Defaults to `[]`.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///   - beforeCursor: The pagination cursor for the previous page; `nil` omits it.
  ///
  /// - Returns: An endpoint that yields `(users: [BannedUser], cursor: String?)` when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getBannedUsers(
    userIDs: [String] = [],
    limit: Int? = nil,
    after afterCursor: String? = nil,
    before beforeCursor: String? = nil
  ) -> HelixEndpoint<
    (users: [BannedUser], cursor: String?), BannedUser,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "moderation/banned",
      queryItems: { credentials in
        [
          ("broadcaster_id", credentials.userID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
          ("before", beforeCursor),
        ] + userIDs.map { ("user_id", $0) }
      },
      makeResponse: {
        ($0.data, $0.pagination?.cursor)
      })
  }
}

/// An account banned or timed out in a channel, with moderation metadata.
@MemberwiseInit(.public)
public struct BannedUser: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  /// The time the resource expires.
  public let expiresAt: Date
  /// The time the resource was created.
  public let createdAt: Date

  /// The reason supplied for this action, when provided.
  public let reason: String?

  /// The Twitch user ID of the moderator.
  public let moderatorID: String
  /// The login name of the moderator.
  public let moderatorLogin: String
  /// The display name of the moderator.
  public let moderatorDisplayName: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case expiresAt
    case createdAt
    case reason
    case moderatorID = "moderatorId"
    case moderatorLogin
    case moderatorDisplayName = "moderatorName"
  }
}
