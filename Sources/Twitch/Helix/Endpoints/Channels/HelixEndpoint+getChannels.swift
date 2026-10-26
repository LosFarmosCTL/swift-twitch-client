import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getChannels(_ broadcasterIDs: [String])
    -> HelixEndpoint<[Broadcaster], Broadcaster, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "channels",
      queryItems: { _ in
        broadcasterIDs.map { ("broadcaster_id", $0) }
      }, makeResponse: { $0.data })
  }
}

@MemberwiseInit(.public)
public struct Broadcaster: Decodable, Sendable {
  public let id: String
  public let login: String
  public let displayName: String
  public let language: String
  public let gameID: String
  public let gameName: String
  public let title: String
  public let delay: Int
  public let tags: [String]
  public let contentClassificationLabels: [ContentClassificationLabelID]
  public let isBrandedContent: Bool

  enum CodingKeys: String, CodingKey {
    case id = "broadcasterId"
    case login = "broadcasterLogin"
    case displayName = "broadcasterName"
    case language = "broadcasterLanguage"
    case gameID = "gameId"
    case gameName
    case title
    case delay
    case tags
    case contentClassificationLabels
    case isBrandedContent
  }
}
