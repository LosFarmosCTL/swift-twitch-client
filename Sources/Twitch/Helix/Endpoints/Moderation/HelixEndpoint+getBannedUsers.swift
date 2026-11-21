import Foundation

extension HelixEndpoint {
  /// Gets users banned or timed out from the authenticated broadcaster’s channel.
  ///
  /// With a user access token, requires `moderation:read` or
  /// `moderator:manage:banned_users`. App tokens have additional grant requirements
  /// described in the reference.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/moderation/#get-banned-users
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - broadcasterID: The acting user ID. Required with app tokens; otherwise defaults
  ///     to the user token’s identity.
  ///   - userIDs: The user IDs to include in the request. Defaults to `[]`.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - cursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields ``BannedUsersResponse`` when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getBannedUsers(
    userIDs: [String] = [],
    limit: Int? = nil,
    after cursor: String? = nil,
    broadcasterID: String? = nil
  ) -> HelixEndpoint<BannedUsersResponse> {
    .init(
      method: "GET", path: "moderation/banned",
      authentication: .either,
      queryItems: { credentials in
        [
          (
            "broadcaster_id",
            try credentials.resolveUserID(
              broadcasterID, parameter: "broadcaster_id", matchingToken: true)
          ),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ] + userIDs.map { ("user_id", $0) }
      },
      responseType: BannedUser.self,
      makeResponse: {
        BannedUsersResponse(users: $0.data, cursor: $0.pagination?.cursor)
      })
  }
}

/// An account banned or timed out in a channel, with moderation metadata.
public struct BannedUser: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  /// The timeout expiry; `nil` for a permanent ban.
  public let expiresAt: Date?
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

  /// Creates a `BannedUser` value.
  public init(
    userID: String,
    userLogin: String,
    userDisplayName: String,
    expiresAt: Date? = nil,
    createdAt: Date,
    reason: String? = nil,
    moderatorID: String,
    moderatorLogin: String,
    moderatorDisplayName: String
  ) {
    self.userID = userID
    self.userLogin = userLogin
    self.userDisplayName = userDisplayName
    self.expiresAt = expiresAt
    self.createdAt = createdAt
    self.reason = reason
    self.moderatorID = moderatorID
    self.moderatorLogin = moderatorLogin
    self.moderatorDisplayName = moderatorDisplayName
  }

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

  /// Decodes a banned user, treating an empty `expires_at` timestamp as `nil`.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    userID = try container.decode(String.self, forKey: .userID)
    userLogin = try container.decode(String.self, forKey: .userLogin)
    userDisplayName = try container.decode(String.self, forKey: .userDisplayName)
    expiresAt = container.decodeLenientDateIfPresent(forKey: .expiresAt)
    createdAt = try container.decode(Date.self, forKey: .createdAt)
    reason = try container.decodeIfPresent(String.self, forKey: .reason)
    moderatorID = try container.decode(String.self, forKey: .moderatorID)
    moderatorLogin = try container.decode(String.self, forKey: .moderatorLogin)
    moderatorDisplayName = try container.decode(String.self, forKey: .moderatorDisplayName)
  }
}

/// A page of banned users.
public struct BannedUsersResponse: Sendable {
  /// The users on this page.
  public let users: [BannedUser]
  /// The next-page cursor, if Twitch returned one.
  public let cursor: String?

  /// Creates a `BannedUsersResponse` value.
  public init(
    users: [BannedUser] = [],
    cursor: String? = nil
  ) {
    self.users = users
    self.cursor = cursor
  }
}
