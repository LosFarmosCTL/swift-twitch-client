import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == [Broadcaster], HelixResponseType == Broadcaster
{
  public static func getChannels(_ channels: [UserID]) -> Self {
    return .init(
      method: "GET", path: "channels",
      queryItems: { _ in
        channels.map { ("broadcaster_id", $0) }
      },
      makeResponse: { result in
        result.data
      }
    )
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
