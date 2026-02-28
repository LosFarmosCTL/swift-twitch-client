import Foundation

extension HelixEndpoint {
  public static func getChannels(_ channels: [String])
    -> HelixEndpoint<[Broadcaster], Broadcaster, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "channels",
      queryItems: { _ in
        channels.map { ("broadcaster_id", $0) }
      }, makeResponse: { $0.data })
  }
}

public struct Broadcaster: Decodable, Sendable {
  public let id: String
  public let login: String
  public let name: String
  public let language: String
  public let gameID: String
  public let gameName: String
  public let title: String
  public let delay: Int
  public let tags: [String]
  public let contentClassificationLabels: [Label]
  public let isBrandedContent: Bool

  enum CodingKeys: String, CodingKey {
    case id = "broadcasterId"
    case login = "broadcasterLogin"
    case name = "broadcasterName"
    case language = "broadcasterLanguage"
    case gameID = "gameId"
    case gameName, title, delay, tags
    case contentClassificationLabels
    case isBrandedContent
  }
}
