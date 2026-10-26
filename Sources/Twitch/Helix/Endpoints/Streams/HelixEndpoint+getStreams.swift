import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets live streams matching the supplied filters.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-streams
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - userIDs: The user IDs to include in the request. Defaults to `[]`.
  ///   - userLogins: The user logins to include in the request. Defaults to `[]`.
  ///   - gameIDs: The game IDs to include in the request. Defaults to `[]`.
  ///   - type: The stream type filter; `nil` uses Twitch’s default of all stream types.
  ///   - languages: The language codes to include. Defaults to `[]`.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - beforeCursor: The pagination cursor for the previous page; `nil` omits it.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields `(streams: [Stream], cursor: String?)` when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getStreams(
    userIDs: [String] = [],
    userLogins: [String] = [],
    gameIDs: [String] = [],
    type: StreamTypeFilter? = nil,
    languages: [String] = [],
    limit: Int? = nil,
    before beforeCursor: String? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (streams: [Stream], cursor: String?),
    Stream, HelixEndpointResponseTypes.Normal
  > {
    let userIDs = userIDs.compactMap { ("user_id", $0) }
    let userLogins = userLogins.compactMap { ("user_login", $0) }
    let gameIDs = gameIDs.compactMap { ("game_id", $0) }
    let languages = languages.compactMap { ("language", $0) }

    return .init(
      method: "GET", path: "streams",
      queryItems: { _ in
        [
          ("type", type?.rawValue),
          ("first", limit.map(String.init)),
          ("before", beforeCursor),
          ("after", afterCursor),
        ] + userIDs + userLogins + gameIDs + languages
      }, makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

/// The stream types to include when querying broadcasts.
public enum StreamTypeFilter: String, Sendable {
  /// Only live streams.
  case live
  /// Includes all supported entries or periods.
  case all
}

/// A live broadcast’s channel identity, category, title, and audience metadata.
@MemberwiseInit(.public)
public struct Stream: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String

  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  /// The identifier of the game.
  public let gameID: String
  /// The name of the game.
  public let gameName: String

  /// Twitch’s stream type; normally `"live"`, or an empty string if unavailable.
  public let type: String
  /// The title shown to viewers.
  public let title: String
  /// The language code reported by Twitch.
  public let language: String
  /// The stream tags.
  public let tags: [String]
  /// Whether the content is marked as mature.
  public let isMature: Bool

  /// The number of viewers reported by Twitch.
  public let viewerCount: Int
  /// The time the activity started.
  public let startedAt: Date
  /// The URL for thumbnail.
  public let thumbnailURL: String

  enum CodingKeys: String, CodingKey {
    case id
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case gameID = "gameId"
    case gameName
    case type
    case title
    case language
    case tags
    case isMature
    case viewerCount
    case startedAt
    case thumbnailURL = "thumbnailUrl"
  }
}
