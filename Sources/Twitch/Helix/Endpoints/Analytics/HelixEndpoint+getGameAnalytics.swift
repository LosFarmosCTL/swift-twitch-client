import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ([GameReport], PaginationCursor?), HelixResponseType == GameReport
{
  public static func getGameAnalytics(
    gameID: String? = nil, type: String? = nil, range: DateInterval? = nil,
    limit: Int? = nil, after cursor: String? = nil
  ) -> Self {
    return .init(
      method: "GET", path: "analytics/games",
      queryItems: { _ in
        [
          ("game_id", gameID),
          ("type", type),
          ("started_at", range?.start.formatted(.iso8601)),
          ("ended_at", range?.end.formatted(.iso8601)),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      }, makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

public struct GameReport: Decodable {
  let gameID: String
  let url: String
  let type: String
  let range: DateInterval

  enum CodingKeys: String, CodingKey {
    case gameID = "game_id"
    case url = "URL"
    case type
    case range = "date_range"
  }

  enum DateRangeCodingKeys: String, CodingKey {
    case startedAt = "started_at"
    case endedAt = "ended_at"
  }

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
