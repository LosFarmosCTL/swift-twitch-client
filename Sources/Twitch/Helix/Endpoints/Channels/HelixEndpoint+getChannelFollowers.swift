import Foundation

extension HelixEndpoint {
  /// Gets a broadcaster’s followers and follower count.
  ///
  /// Requires a user access token. Follower details require `moderator:read:followers`
  /// and a token for the broadcaster or a channel moderator. Without those permissions,
  /// Twitch returns only the total for unfiltered requests.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/channels/#get-channel-followers
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  ///   - userID: When provided, only returns a matching follower. Requires follower-detail
  ///     authorization.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - cursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  public static func getChannelFollowers(
    of broadcasterID: String? = nil,
    userID: String? = nil,
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<FollowersResponse> {
    .init(
      method: "GET", path: "channels/followers",
      authentication: .user,
      queryItems: { credentials in
        [
          (
            "broadcaster_id",
            try credentials.resolveUserID(broadcasterID, parameter: "broadcaster_id")
          ),
          ("user_id", userID),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      },
      responseType: Follower.self,
      makeResponse: {
        let total = try $0.require(\.total)

        return FollowersResponse(
          total: total,
          followers: $0.data,
          cursor: $0.pagination?.cursor)
      })
  }

  /// Checks whether a user follows a broadcaster.
  ///
  /// Requires the broadcaster’s or a channel moderator’s user token with
  /// `moderator:read:followers`. Twitch rejects unauthorized filtered requests.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/channels/#get-channel-followers
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - userID: The Twitch user ID.
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  ///
  /// - Returns: An endpoint that yields matching follow details when executed, or `nil`
  ///   when Twitch returns no matching entry.
  public static func checkFollower(_ userID: String, follows broadcasterID: String? = nil)
    -> HelixEndpoint<Follower?>
  {
    .init(
      method: "GET", path: "channels/followers",
      authentication: .user,
      queryItems: { credentials in
        [
          ("user_id", userID),
          (
            "broadcaster_id",
            try credentials.resolveUserID(broadcasterID, parameter: "broadcaster_id")
          ),
        ]
      },
      responseType: Follower.self, makeResponse: { $0.data.first })
  }
}

/// A page of channel followers, the follower count, and the next pagination cursor.
public struct FollowersResponse: Sendable {
  /// The total number of users following the broadcaster.
  public let total: Int

  /// The users following the channel.
  public let followers: [Follower]

  /// The pagination cursor to pass when requesting another page.
  public let cursor: String?

  /// Creates a `FollowersResponse` value.
  public init(
    total: Int,
    followers: [Follower] = [],
    cursor: String? = nil
  ) {
    self.total = total
    self.followers = followers
    self.cursor = cursor
  }
}

/// A channel follower’s identity and the time the follow began.
public struct Follower: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String
  /// The time the user followed the channel.
  public let followedAt: Date

  /// Creates a `Follower` value.
  public init(
    userID: String,
    userLogin: String,
    userDisplayName: String,
    followedAt: Date
  ) {
    self.userID = userID
    self.userLogin = userLogin
    self.userDisplayName = userDisplayName
    self.followedAt = followedAt
  }

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case followedAt
  }
}
