import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getChannels(userIDs: [String]) async throws -> [Broadcaster] {
    let queryItems = userIDs.map { URLQueryItem(name: "broadcaster_id", value: $0) }

    var data: Data
    data = try await self.request(.get("channels"), with: queryItems)

    guard let channels = try? JSONDecoder().decode(HelixData<Broadcaster>.self, from: data).data
    else {
      throw HelixError.invalidResponse(rawResponse: String(decoding: data, as: UTF8.self))
    }

    return channels
  }
}

public struct Broadcaster: Codable {
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
