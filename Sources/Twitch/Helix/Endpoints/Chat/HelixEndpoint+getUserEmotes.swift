import MemberwiseInit

extension HelixEndpoint {
  /// Gets the emotes available to the authenticated user across all channels.
  ///
  /// Requires a user access token with `user:read:emotes`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-user-emotes
  /// ).
  ///
  /// - Parameters:
  ///   - broadcasterID: A broadcaster whose follower emotes should be included.
  ///   - afterCursor: The next-page cursor, if any.
  /// - Returns: Emotes, their image URL template, and the next-page cursor.
  public static func getUserEmotes(
    broadcasterID: String? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<UserEmotesResponse, SetEmote, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "chat/emotes/user",
      authentication: .user,
      queryItems: { credentials in
        [
          ("user_id", try credentials.requireUser().id),
          ("broadcaster_id", broadcasterID),
          ("after", afterCursor),
        ]
      },
      makeResponse: {
        UserEmotesResponse(
          emotes: $0.data, template: try $0.require(\.template),
          cursor: $0.pagination?.cursor)
      })
  }
}

/// A page of a user’s available emotes, with their image URL template.
@MemberwiseInit(.public)
public struct UserEmotesResponse: Sendable {
  /// The emotes available on this page.
  public let emotes: [SetEmote]
  /// The URL template used by each emote’s `getURL(from:format:scale:themeMode:)` method.
  public let template: String
  /// The next-page cursor; `nil` when there are no more pages.
  public let cursor: String?
}
