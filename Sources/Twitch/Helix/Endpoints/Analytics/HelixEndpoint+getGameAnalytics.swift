import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets downloadable analytics reports for games owned by the authenticated user’s
  /// organization.
  ///
  /// With a user access token, requires `analytics:read:games`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-game-analytics
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - gameID: The identifier of the game, when provided.
  ///   - type: The analytics report format; Twitch currently supports `"overview_v2"`.
  ///   - range: The date interval used to restrict the results.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields `(reports: [GameReport], cursor: String?)` when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getGameAnalytics(
    gameID: String? = nil,
    type: String? = nil,
    range: DateInterval? = nil,
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (reports: [GameReport], cursor: String?),
    GameReport, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "analytics/games",
      queryItems: { _ in
        [
          ("game_id", gameID),
          ("type", type),
          ("started_at", range?.start.formatted(.iso8601)),
          ("ended_at", range?.end.formatted(.iso8601)),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      }, makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

/// A downloadable game analytics report and its covered date range.
@MemberwiseInit(.public)
public struct GameReport: Decodable, Sendable {
  /// The identifier of the game.
  public let gameID: String
  /// The URL associated with this resource.
  public let url: String
  /// The analytics report format requested from Twitch.
  public let type: String
  /// The date range covered by the response.
  public let range: DateInterval

  enum CodingKeys: String, CodingKey {
    case gameID = "gameId"
    case url = "URL"
    case type
    case range = "dateRange"
  }

  enum DateRangeCodingKeys: String, CodingKey {
    case startedAt, endedAt
  }

  /// Decodes a report, combining its start and end timestamps into `range`.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.gameID = try container.decode(String.self, forKey: .gameID)
    self.url = try container.decode(String.self, forKey: .url)
    self.type = try container.decode(String.self, forKey: .type)

    let rangeContainer = try container.nestedContainer(
      keyedBy: DateRangeCodingKeys.self, forKey: .range)

    let startedAt = try rangeContainer.decode(Date.self, forKey: .startedAt)
    let endedAt = try rangeContainer.decode(Date.self, forKey: .endedAt)

    self.range = DateInterval(start: startedAt, end: endedAt)
  }
}
