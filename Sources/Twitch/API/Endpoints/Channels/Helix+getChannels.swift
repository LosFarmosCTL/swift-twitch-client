import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getChannels(userIDs: [String]) async throws -> [Broadcaster] {
    let queryItems = userIDs.map { URLQueryItem(name: "broadcaster_id", value: $0) }

    let (rawResponse, result): (_, HelixData<Broadcaster>?) = try await self.request(
      .get("channels"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return result.data
  }
}

public struct Broadcaster: Decodable {
  let id: String
  let login: String
  let name: String
  let language: String
  let gameID: String
  let gameName: String
  let title: String
  let delay: Int
  let tags: [String]

  enum CodingKeys: String, CodingKey {
    case id = "broadcaster_id"
    case login = "broadcaster_login"
    case name = "broadcaster_name"
    case language = "broadcaster_language"
    case gameID = "game_id"
    case gameName = "game_name"
    case title
    case delay
    case tags
  }
}
