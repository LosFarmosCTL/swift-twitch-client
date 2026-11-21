import Foundation

extension HelixEndpoint {
  /// Searches Twitch channels, optionally restricting results to live channels.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/search/#search-channels
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - query: The search text.
  ///   - liveOnly: Whether to restrict results to live channels.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - cursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields ``SearchChannelsResponse`` when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func searchChannels(
    for query: String,
    liveOnly: Bool? = nil,
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<SearchChannelsResponse> {
    .init(
      method: "GET", path: "search/channels",
      authentication: .either,
      queryItems: { _ in
        [
          ("query", query),
          ("live_only", liveOnly.map(String.init)),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      },
      responseType: Channel.self,
      makeResponse: {
        SearchChannelsResponse(channels: $0.data, cursor: $0.pagination?.cursor)
      })
  }
}

/// A channel returned by channel search, including its broadcast metadata.
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

  /// The URL of the channel's profile image.
  public let profileImageURL: String
  /// The title shown to viewers.
  public let title: String

  /// The time the activity started, when provided.
  public let startedAt: Date?

  /// Creates a `Channel` value.
  public init(
    id: String,
    login: String,
    displayName: String,
    language: String,
    gameID: String,
    gameName: String,
    isLive: Bool,
    tags: [String] = [],
    profileImageURL: String,
    title: String,
    startedAt: Date? = nil
  ) {
    self.id = id
    self.login = login
    self.displayName = displayName
    self.language = language
    self.gameID = gameID
    self.gameName = gameName
    self.isLive = isLive
    self.tags = tags
    self.profileImageURL = profileImageURL
    self.title = title
    self.startedAt = startedAt
  }

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

  /// Decodes a channel search result, treating an empty `started_at` timestamp as `nil`.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    login = try container.decode(String.self, forKey: .login)
    displayName = try container.decode(String.self, forKey: .displayName)
    language = try container.decode(String.self, forKey: .language)
    gameID = try container.decode(String.self, forKey: .gameID)
    gameName = try container.decode(String.self, forKey: .gameName)
    isLive = try container.decode(Bool.self, forKey: .isLive)
    tags = try container.decode([String].self, forKey: .tags)
    profileImageURL = try container.decode(String.self, forKey: .profileImageURL)
    title = try container.decode(String.self, forKey: .title)
    startedAt = container.decodeLenientDateIfPresent(forKey: .startedAt)
  }
}

/// A page of search channels.
public struct SearchChannelsResponse: Sendable {
  /// The channels on this page.
  public let channels: [Channel]
  /// The next-page cursor, if Twitch returned one.
  public let cursor: String?

  /// Creates a `SearchChannelsResponse` value.
  public init(
    channels: [Channel] = [],
    cursor: String? = nil
  ) {
    self.channels = channels
    self.cursor = cursor
  }
}
