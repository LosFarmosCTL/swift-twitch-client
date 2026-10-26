import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets predictions from the `extensions/predictions` route.
  ///
  /// This route is not listed in the current Twitch API reference; availability and
  /// authorization requirements are not documented by Twitch.
  ///
  /// - Parameters:
  ///   - extensionID: The identifier of the extension.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields matching items and a pagination cursor when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getExtensionPredictions(
    extensionID: String,
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (predictions: [ExtensionPrediction], cursor: String?), ExtensionPrediction,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "extensions/predictions",
      queryItems: { _ in
        [
          ("extension_id", extensionID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

/// An extension’s prediction and its available outcomes.
@MemberwiseInit(.public)
public struct ExtensionPrediction: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String
  /// The title shown to viewers.
  public let title: String
  /// The prediction outcomes.
  public let outcomes: [ExtensionPredictionOutcome]
  /// The time viewers have to make predictions, in seconds.
  public let predictionWindow: Int
  /// The time the resource was created.
  public let createdAt: Date
  /// The time the activity ended, when provided.
  public let endedAt: Date?

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterDisplayName = "broadcasterName"
    case title
    case outcomes
    case predictionWindow
    case createdAt
    case endedAt
  }
}

/// An outcome of an extension prediction.
@MemberwiseInit(.public)
public struct ExtensionPredictionOutcome: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The title shown to viewers.
  public let title: String
  /// The number of viewers who selected this prediction outcome.
  public let users: Int
  /// The number of Channel Points.
  public let channelPoints: Int
  /// The color reported by Twitch.
  public let color: Color

  /// The display color assigned to a prediction outcome.
  public enum Color: String, Decodable, Sendable {
    /// The pink prediction outcome. Encoded as `"PINK"`.
    case pink = "PINK"
    /// The blue prediction outcome. Encoded as `"BLUE"`.
    case blue = "BLUE"
  }
}
