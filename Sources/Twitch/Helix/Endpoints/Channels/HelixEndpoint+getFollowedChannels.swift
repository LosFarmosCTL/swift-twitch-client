import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets channels followed by the authenticated user.
  ///
  /// With a user access token, requires `user:read:follows`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-followed-channels
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `user_id`.
  ///
  /// - Parameters:
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  public static func getFollowedChannels(
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    FollowedChannelsResponse, Follow, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "channels/followed",
      authentication: .user,
      queryItems: { credentials in
        [
          ("user_id", try credentials.requireUser().id),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      },
      makeResponse: {
        let total = try $0.require(\.total)

        return FollowedChannelsResponse(
          total: total,
          follows: $0.data,
          cursor: $0.pagination?.cursor)
      })
  }

  /// Checks whether the authenticated user follows a broadcaster.
  ///
  /// With a user access token, requires `user:read:follows`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-followed-channels
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `user_id`.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///
  /// - Returns: An endpoint that yields matching follow details when executed, or `nil`
  ///   when Twitch returns no matching entry.
  public static func checkFollow(to broadcasterID: String)
    -> HelixEndpoint<Follow?, Follow, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "channels/followed",
      authentication: .user,
      queryItems: { credentials in
        [
          ("user_id", try credentials.requireUser().id),
          ("broadcaster_id", broadcasterID),
        ]
      },
      makeResponse: { $0.data.first })
  }
}

/// A page of followed channels, the total followed count, and the next cursor.
public struct FollowedChannelsResponse: Sendable {
  /// The number of channels followed by the authenticated user across all pages.
  public let total: Int

  /// The followed channels.
  public let follows: [Follow]

  /// The pagination cursor to pass when requesting another page.
  public let cursor: String?
}

/// A followed broadcaster’s identity and the time the follow began.
@MemberwiseInit(.public)
public struct Follow: Decodable, Sendable {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String
  /// The time the user followed the channel.
  public let followedAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterDisplayName = "broadcasterName"
    case followedAt
  }
}
