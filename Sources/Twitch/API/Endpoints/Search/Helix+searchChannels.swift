import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<Channel> {
  public static func searchChannels(
    for searchQuery: String,
    liveOnly: Bool? = nil,
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("query", searchQuery),
      ("live_only", liveOnly.map(String.init)),
      ("after", cursor),
      ("first", limit.map(String.init)))

    return .init(method: "GET", path: "search/channels", queryItems: queryItems)
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
