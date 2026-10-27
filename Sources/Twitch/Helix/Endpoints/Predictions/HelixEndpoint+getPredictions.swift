import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets predictions from the authenticated broadcaster’s channel.
  ///
  /// With a user access token, requires `channel:read:predictions` or
  /// `channel:manage:predictions`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-predictions
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - predictionIDs: The prediction IDs to include in the request. Defaults to `[]`.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields matching items and a pagination cursor when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getPredictions(
    predictionIDs: [String] = [],
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (predictions: [Prediction], cursor: String?), Prediction,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "predictions",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", try credentials.requireUser().id),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ] + predictionIDs.map { ("id", $0) }
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

/// A channel prediction’s outcomes, participation window, lifecycle, and result.
@MemberwiseInit(.public)
public struct Prediction: Decodable, Sendable {
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
  /// The identifier of the winning outcome, when provided.
  public let winningOutcomeID: String?

  /// The prediction outcomes.
  public let outcomes: [PredictionOutcome]
  /// The time viewers have to make predictions, in seconds.
  public let predictionWindow: Int
  /// The prediction’s wagering, lock, resolution, or cancellation state.
  public let status: Status

  /// The time the resource was created.
  public let createdAt: Date
  /// The time the activity ended, when provided.
  public let endedAt: Date?
  /// The time the prediction was locked, when provided.
  public let lockedAt: Date?

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterDisplayName = "broadcasterName"
    case title
    case winningOutcomeID = "winningOutcomeId"
    case outcomes
    case predictionWindow
    case status
    case createdAt
    case endedAt
    case lockedAt
  }

  /// The prediction’s wagering, lock, resolution, or cancellation state.
  public enum Status: String, Decodable, Sendable {
    /// The poll or prediction is accepting participation. Encoded as `"ACTIVE"`.
    case active = "ACTIVE"
    /// The prediction has a declared winning outcome. Encoded as `"RESOLVED"`.
    case resolved = "RESOLVED"
    /// The operation was cancelled. Encoded as `"CANCELED"`.
    case cancelled = "CANCELED"
    /// The prediction no longer accepts participation. Encoded as `"LOCKED"`.
    case locked = "LOCKED"
  }
}

/// A prediction outcome and its participating users and Channel Points totals.
@MemberwiseInit(.public)
public struct PredictionOutcome: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The title shown to viewers.
  public let title: String
  /// The number of viewers who selected this prediction outcome.
  public let users: Int
  /// The number of Channel Points.
  public let channelPoints: Int
  /// The top predictors for this outcome, when provided.
  public let topPredictors: [TopPredictor]?
  /// The color reported by Twitch.
  public let color: Color

  /// The display color assigned to a prediction outcome.
  public enum Color: String, Decodable, Sendable {
    /// The pink prediction outcome. Encoded as `"PINK"`.
    case pink = "PINK"
    /// The blue prediction outcome. Encoded as `"BLUE"`.
    case blue = "BLUE"
  }

  /// A leading viewer’s wager and winnings for a prediction outcome.
  @MemberwiseInit(.public)
  public struct TopPredictor: Decodable, Sendable {
    /// The Twitch user ID.
    public let userID: String
    /// The user’s login name.
    public let userLogin: String
    /// The user’s display name.
    public let userDisplayName: String

    /// The Channel Points spent on the prediction outcome.
    public let channelPointsUsed: Int
    /// The Channel Points awarded for the prediction outcome, when provided.
    public let channelPointsWon: Int?

    enum CodingKeys: String, CodingKey {
      case userID = "userId"
      case userLogin
      case userDisplayName = "userName"
      case channelPointsUsed
      case channelPointsWon
    }
  }
}
