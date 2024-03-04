import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ([Channel], PaginationCursor?), HelixResponseType == Channel
{
  public static func searchChannels(
    for searchQuery: String,
    liveOnly: Bool? = nil,
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> Self {
    return .init(
      method: "GET", path: "search/channels",
      queryItems: { _ in
        [
          ("query", searchQuery),
          ("live_only", liveOnly.map(String.init)),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      },
      makeResponse: {
        ($0.data, $0.pagination?.cursor)
      })
  }
}

public struct Channel: Decodable {
  let id: String
  let login: String
  let name: String
  let language: String

  let gameID: String
  let gameName: String

  let isLive: Bool
  let tags: [String]

  let profilePictureURL: String
  let title: String
  @NilOnTypeMismatch var startedAt: Date?

  enum CodingKeys: String, CodingKey {
    case id
    case login = "broadcaster_login"
    case name = "display_name"
    case language = "broadcaster_language"

    case gameID = "game_id"
    case gameName = "game_name"

    case isLive = "is_live"
    case tags

    case profilePictureURL = "thumbnail_url"
    case title
    case startedAt = "started_at"
  }
}

@propertyWrapper struct NilOnTypeMismatch<Value> { var wrappedValue: Value? }

extension NilOnTypeMismatch: Decodable where Value: Decodable {
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.wrappedValue = try? container.decode(Value.self)
  }
}
