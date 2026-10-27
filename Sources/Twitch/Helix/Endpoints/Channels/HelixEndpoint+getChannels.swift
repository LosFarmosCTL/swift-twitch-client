import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets channel information for the requested broadcasters.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-channel-information
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterIDs: The broadcaster IDs to include in the request.
  public static func getChannels(_ broadcasterIDs: [String])
    -> HelixEndpoint<[Broadcaster], Broadcaster, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "channels",
      authentication: .either,
      queryItems: { _ in
        broadcasterIDs.map { ("broadcaster_id", $0) }
      }, makeResponse: { $0.data })
  }
}

/// A broadcaster’s channel metadata returned by the channel-information endpoint.
@MemberwiseInit(.public)
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
