import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets live channels with the specified extension active.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-extension-live-channels
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - extensionID: The identifier of the extension.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields matching items and a pagination cursor when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getExtensionLiveChannels(
    extensionID: String,
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (channels: [ExtensionLiveChannel], cursor: String?), ExtensionLiveChannel,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "extensions/live",
      queryItems: { _ in
        [
          ("extension_id", extensionID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      },
      makeResponse: {
        ($0.data, $0.pagination?.cursor)
      })
  }
}

/// A live channel using an extension.
@MemberwiseInit(.public)
public struct ExtensionLiveChannel: Decodable, Sendable {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String
  /// The identifier of the game.
  public let gameID: String
  /// The name of the game.
  public let gameName: String
  /// The title shown to viewers.
  public let title: String

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case gameID = "gameId"
    case broadcasterDisplayName = "broadcasterName"
    case gameName
    case title
  }
}
