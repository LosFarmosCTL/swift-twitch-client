import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Searches Twitch channels, optionally restricting results to live channels.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#search-channels
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - query: The search text.
  ///   - liveOnly: Whether to restrict results to live channels.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields `(channels: [Channel], cursor: String?)` when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func searchChannels(
    for query: String,
    liveOnly: Bool? = nil,
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (channels: [Channel], cursor: String?),
    Channel, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "search/channels",
      queryItems: { _ in
        [
          ("query", query),
          ("live_only", liveOnly.map(String.init)),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

/// A channel returned by channel search, including its broadcast metadata.
@MemberwiseInit(.public)
public struct Channel: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The account’s login name.
  public let login: String
  /// The display name shown on Twitch.
  public let displayName: String
  /// The language code reported by Twitch.
  public let language: String

  /// The identifier of the game.
  public let gameID: String
  /// The name of the game.
  public let gameName: String

  /// Whether the channel is currently live.
  public let isLive: Bool
  /// The stream tags.
  public let tags: [String]

  /// The URL for profile image.
  public let profileImageURL: String
  /// The title shown to viewers.
  public let title: String

  /// The time the activity started, when provided.
  @InitRaw(default: nil, type: Date?.self)
  @NilOnTypeMismatch public var startedAt: Date?

  enum CodingKeys: String, CodingKey {
    case id
    case login = "broadcasterLogin"
    case displayName
    case language = "broadcasterLanguage"
    case gameID = "gameId"
    case gameName
    case isLive
    case tags
    case profileImageURL = "thumbnailUrl"
    case title
    case startedAt
  }
}
