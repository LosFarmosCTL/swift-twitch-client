import Foundation

extension HelixEndpoint {
  /// Gets channel information for the requested broadcasters.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/channels/#get-channel-information
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterIDs: The broadcaster IDs to include in the request.
  public static func getChannels(_ broadcasterIDs: [String])
    -> HelixEndpoint<[Broadcaster]>
  {
    .init(
      method: "GET", path: "channels",
      authentication: .either,
      queryItems: { _ in
        broadcasterIDs.map { ("broadcaster_id", $0) }
      }, responseType: Broadcaster.self, makeResponse: { $0.data })
  }
}

/// A broadcaster’s channel metadata returned by the channel-information endpoint.
public struct Broadcaster: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The account’s login name.
  public let login: String
  /// The display name shown on Twitch.
  public let displayName: String
  /// The language code reported by Twitch.
  public let language: String
  /// The identifier of the game.
  public let gameID: String
  /// The name of the game.
  public let gameName: String
  /// The title shown to viewers.
  public let title: String
  /// The broadcast delay in seconds.
  public let delay: Int
  /// The stream tags.
  public let tags: [String]
  /// The content classification labels.
  public let contentClassificationLabels: [ContentClassificationLabelID]
  /// Whether the stream is marked as branded content.
  public let isBrandedContent: Bool

  /// Creates a `Broadcaster` value.
  public init(
    id: String,
    login: String,
    displayName: String,
    language: String,
    gameID: String,
    gameName: String,
    title: String,
    delay: Int,
    tags: [String] = [],
    contentClassificationLabels: [ContentClassificationLabelID] = [],
    isBrandedContent: Bool
  ) {
    self.id = id
    self.login = login
    self.displayName = displayName
    self.language = language
    self.gameID = gameID
    self.gameName = gameName
    self.title = title
    self.delay = delay
    self.tags = tags
    self.contentClassificationLabels = contentClassificationLabels
    self.isBrandedContent = isBrandedContent
  }

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
