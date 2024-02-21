import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<Broadcaster> {
  public static func getChannels(userIDs: [String]) -> Self {
    let queryItems = userIDs.map { URLQueryItem(name: "broadcaster_id", value: $0) }

    return .init(method: "GET", path: "channels", queryItems: queryItems)
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
