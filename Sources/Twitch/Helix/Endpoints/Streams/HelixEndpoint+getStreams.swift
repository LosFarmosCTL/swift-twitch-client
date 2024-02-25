import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<Stream> {
  public static func getStreams(
    userIDs: [String] = [],
    userLogins: [String] = [],
    gameIDs: [String] = [],
    type: StreamType? = nil,
    languages: [String] = [],
    limit: Int? = nil,
    before endCursor: String? = nil,
    after startCursor: String? = nil
  ) -> Self {
    let userIDs = userIDs.compactMap { URLQueryItem(name: "user_id", value: $0) }
    let userLogins = userLogins.compactMap { URLQueryItem(name: "user_login", value: $0) }
    let gameIDs = gameIDs.compactMap { URLQueryItem(name: "game_id", value: $0) }
    let languages = languages.compactMap { URLQueryItem(name: "language", value: $0) }

    let type = type.map { URLQueryItem(name: "type", value: $0.rawValue) }
    let limit = limit.map { URLQueryItem(name: "first", value: String($0)) }
    let before = endCursor.map { URLQueryItem(name: "before", value: $0) }
    let after = startCursor.map { URLQueryItem(name: "after", value: $0) }

    var queryItems = userIDs + userLogins + gameIDs + languages
    queryItems.append(contentsOf: [type, limit, before, after].compactMap { $0 })

    return .init(method: "GET", path: "streams", queryItems: queryItems)
  }
}

public enum StreamType: String {
  case live
  case all
}

public struct Stream: Decodable {
  let id: String

  let userID: String
  let userLogin: String
  let userName: String

  let gameID: String
  let gameName: String

  let type: String
  let title: String
  let language: String
  let tags: [String]
  let isMature: Bool

  let viewerCount: Int
  let startedAt: Date
  let thumbnailURL: String

  enum CodingKeys: String, CodingKey {
    case id
    case userID = "user_id"
    case userLogin = "user_login"
    case userName = "user_name"

    case gameID = "game_id"
    case gameName = "game_name"

    case type
    case title
    case language
    case tags
    case isMature = "is_mature"

    case viewerCount = "viewer_count"
    case startedAt = "started_at"
    case thumbnailURL = "thumbnail_url"
  }
}
