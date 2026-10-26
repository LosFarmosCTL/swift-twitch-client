import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets users connected to a channel’s chat.
  ///
  /// With a user access token, requires `moderator:read:chatters`. App tokens have
  /// additional grant requirements described in the reference. The moderator ID must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-chatters
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `moderator_id`.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  public static func getChatters(
    in broadcasterID: String,
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<ChattersResponse, Chatter, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "chat/chatters",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", credentials.userID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      },
      makeResponse: {
        let total = try $0.require(\.total)

        return ChattersResponse(
          total: total,
          chatters: $0.data,
          cursor: $0.pagination?.cursor)
      })
  }
}

/// A page of connected chat accounts, the total count, and the next cursor.
public struct ChattersResponse: Sendable {
  /// The number of users connected to chat across all pages; it may change during
  /// pagination.
  public let total: Int

  /// The chat participants.
  public let chatters: [Chatter]

  /// The pagination cursor to pass when requesting another page.
  public let cursor: String?
}

/// The account identity of a user connected to chat.
@MemberwiseInit(.public)
public struct Chatter: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
  }
}
