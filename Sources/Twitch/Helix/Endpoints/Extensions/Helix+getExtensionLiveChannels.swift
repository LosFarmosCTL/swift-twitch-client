import Foundation

extension HelixEndpoint {
  public static func getExtensionLiveChannels(
    extensionID: String,
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<
    ([ExtensionLiveChannel], String?), ExtensionLiveChannel,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "extensions/live",
      queryItems: { _ in
        [
          ("extension_id", extensionID),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      },
      makeResponse: {
        ($0.data, $0.pagination?.cursor)
      })
  }
}

public struct ExtensionLiveChannel: Decodable, Sendable {
  public let broadcasterID: String
  public let broadcasterName: String
  public let gameID: String
  public let gameName: String
  public let title: String

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case gameID = "gameId"
    case broadcasterName, gameName
    case title
  }
}
