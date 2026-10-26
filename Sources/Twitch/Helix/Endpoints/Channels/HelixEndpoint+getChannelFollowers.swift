import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets a broadcaster’s followers and follower count.
  ///
  /// With a user access token, requires `moderator:read:followers`. Follower details
  /// require the broadcaster’s or a channel moderator’s token; otherwise Twitch returns
  /// only the total count.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-channel-followers
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  public static func getChannelFollowers(
    of broadcasterID: String? = nil,
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<FollowersResponse, Follower, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "channels/followers",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID ?? credentials.userID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      },
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
  /// With a user access token, requires `moderator:read:followers`. Follower details
  /// require the broadcaster’s or a channel moderator’s token; otherwise Twitch returns
  /// only the total count.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-channel-followers
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - userID: The Twitch user ID.
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  ///
  /// - Returns: An endpoint that yields matching follow details when executed, or `nil`
  ///   when Twitch returns no matching entry. A missing entry can also reflect
  ///   insufficient follower-detail authorization.
  public static func checkFollower(_ userID: String, follows broadcasterID: String? = nil)
    -> HelixEndpoint<Follower?, Follower, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "channels/followers",
      queryItems: { credentials in
        [("user_id", userID), ("broadcaster_id", broadcasterID ?? credentials.userID)]
      },
      makeResponse: { $0.data.first })
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
}

/// A channel follower’s identity and the time the follow began.
@MemberwiseInit(.public)
public struct Follower: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String
  /// The time the user followed the channel.
  public let followedAt: Date

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case followedAt
  }
}
