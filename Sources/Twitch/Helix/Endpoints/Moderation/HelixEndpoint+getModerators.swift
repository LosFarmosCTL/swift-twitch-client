import Foundation

extension HelixEndpoint {
  /// Gets the authenticated broadcaster’s channel moderators.
  ///
  /// With a user access token, requires `moderation:read` or `channel:manage:moderators`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/moderation/#get-moderators
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - userIDs: The user IDs to include in the request. Defaults to `[]`.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - cursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields ``ModeratorsResponse`` when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getModerators(
    userIDs: [String] = [],
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<ModeratorsResponse> {
    .init(
      method: "GET", path: "moderation/moderators",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", try credentials.requireUserID(parameter: "broadcaster_id")),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ] + userIDs.map { ("user_id", $0) }
      }, responseType: Moderator.self,
      makeResponse: {
        ModeratorsResponse(moderators: $0.data, cursor: $0.pagination?.cursor)
      })
  }
}

/// An account with moderator privileges in a channel.
public struct Moderator: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The account’s login name.
  public let login: String
  /// The display name shown on Twitch.
  public let displayName: String

  /// Creates a `Moderator` value.
  public init(
    id: String,
    login: String,
    displayName: String
  ) {
    self.id = id
    self.login = login
    self.displayName = displayName
  }

  enum CodingKeys: String, CodingKey {
    case id = "userId"
    case login = "userLogin"
    case displayName = "userName"
  }
}

/// A page of moderators.
public struct ModeratorsResponse: Sendable {
  /// The moderators on this page.
  public let moderators: [Moderator]
  /// The next-page cursor, if Twitch returned one.
  public let cursor: String?

  /// Creates a `ModeratorsResponse` value.
  public init(
    moderators: [Moderator] = [],
    cursor: String? = nil
  ) {
    self.moderators = moderators
    self.cursor = cursor
  }
}
