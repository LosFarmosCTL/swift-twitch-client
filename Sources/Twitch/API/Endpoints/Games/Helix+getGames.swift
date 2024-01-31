import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getGames(
    gameIDs: [String] = [], names: [String] = [], igdbIDs: [String] = []
  ) async throws -> [Game] {
    let idQueryItems = gameIDs.map { URLQueryItem(name: "id", value: $0) }
    let nameQueryItems = names.map { URLQueryItem(name: "name", value: $0) }
    let igdbQueryItems = igdbIDs.map { URLQueryItem(name: "igdb_id", value: $0) }

    let queryItems = idQueryItems + nameQueryItems + igdbQueryItems

    let (rawResponse, result): (_, HelixData<Game>?) = try await self.request(
      .get("games"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return result.data
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
