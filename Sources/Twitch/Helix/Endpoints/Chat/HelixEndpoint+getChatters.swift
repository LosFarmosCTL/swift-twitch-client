import Foundation

extension HelixEndpoint {
  /// Gets users connected to a channel’s chat.
  ///
  /// With a user access token, requires `moderator:read:chatters`. App tokens have
  /// additional grant requirements described in the reference. The moderator ID must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/chat/#get-chatters
  /// ) for request limits and account requirements.
  ///
  /// Omit `moderatorID` to use the user token’s identity. App tokens require it explicitly.
  ///
  /// - Parameters:
  ///   - moderatorID: The acting user ID. Required with app tokens; otherwise defaults
  ///     to the user token’s identity.
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - cursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  public static func getChatters(
    in broadcasterID: String,
    limit: Int? = nil,
    after cursor: String? = nil,
    moderatorID: String? = nil
  ) -> HelixEndpoint<ChattersResponse> {
    .init(
      method: "GET", path: "chat/chatters",
      authentication: .either,
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          (
            "moderator_id",
            try credentials.resolveUserID(
              moderatorID, parameter: "moderator_id", matchingToken: true)
          ),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      },
      responseType: Chatter.self,
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

  /// Creates a `ChattersResponse` value.
  public init(
    total: Int,
    chatters: [Chatter] = [],
    cursor: String? = nil
  ) {
    self.total = total
    self.chatters = chatters
    self.cursor = cursor
  }
}

/// The account identity of a user connected to chat.
public struct Chatter: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  /// Creates a `Chatter` value.
  public init(
    userID: String,
    userLogin: String,
    userDisplayName: String
  ) {
    self.userID = userID
    self.userLogin = userLogin
    self.userDisplayName = userDisplayName
  }

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
  }
}
