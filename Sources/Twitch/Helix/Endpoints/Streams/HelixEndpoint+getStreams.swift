import Foundation

extension HelixEndpoint {
  public static func getStreams(
    userIDs: [String] = [],
    userLogins: [String] = [],
    gameIDs: [String] = [],
    type: StreamType? = nil,
    languages: [String] = [],
    limit: Int? = nil,
    before endCursor: String? = nil,
    after startCursor: String? = nil
  ) -> HelixEndpoint<([Stream], String?), Stream, HelixEndpointResponseTypes.Normal> {
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
          ("before", endCursor),
          ("after", startCursor),
        ] + userIDs + userLogins + gameIDs + languages
      }, makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

public enum StreamType: String, Sendable {
  case live
  case all
}

public struct Stream: Decodable, Sendable {
  public let id: String

  public let userID: String
  public let userLogin: String
  public let userName: String

  public let gameID: String
  public let gameName: String

  public let type: String
  public let title: String
  public let language: String
  public let tags: [String]
  public let isMature: Bool

  public let viewerCount: Int
  public let startedAt: Date
  public let thumbnailURL: String

  enum CodingKeys: String, CodingKey {
    case id
    case userID = "userId"
    case userLogin, userName

    case gameID = "gameId"
    case gameName

    case type, title, language, tags, isMature

    case viewerCount
    case startedAt
    case thumbnailURL = "thumbnailUrl"
  }
}
