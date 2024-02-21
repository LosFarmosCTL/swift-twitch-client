import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<Game> {
  public static func getGames(
    gameIDs: [String] = [], names: [String] = [], igdbIDs: [String] = []
  ) -> Self {
    let idQueryItems = gameIDs.map { URLQueryItem(name: "id", value: $0) }
    let nameQueryItems = names.map { URLQueryItem(name: "name", value: $0) }
    let igdbQueryItems = igdbIDs.map { URLQueryItem(name: "igdb_id", value: $0) }

    let queryItems = idQueryItems + nameQueryItems + igdbQueryItems

    return .init(method: "GET", path: "games", queryItems: queryItems)
  }
}

public struct Game: Decodable {
  let id: String
  let name: String
  let boxArtUrl: String
  let igdbId: String

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case boxArtUrl = "box_art_url"
    case igdbId = "igdb_id"
  }
}
