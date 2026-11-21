import Foundation

extension HelixEndpoint {
  /// Gets predictions from the authenticated broadcaster’s channel.
  ///
  /// With a user access token, requires `channel:read:predictions` or
  /// `channel:manage:predictions`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/predictions/#get-predictions
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - predictionIDs: The prediction IDs to include in the request. Defaults to `[]`.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - cursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields matching items and a pagination cursor when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getPredictions(
    predictionIDs: [String] = [],
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<PredictionsResponse> {
    .init(
      method: "GET", path: "predictions",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", try credentials.requireUserID(parameter: "broadcaster_id")),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ] + predictionIDs.map { ("id", $0) }
      },
      responseType: Prediction.self,
      makeResponse: {
        PredictionsResponse(predictions: $0.data, cursor: $0.pagination?.cursor)
      })
  }
}

/// A channel prediction’s outcomes, participation window, lifecycle, and result.
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

  /// Creates a `Prediction` value.
  public init(
    id: String,
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    title: String,
    winningOutcomeID: String? = nil,
    outcomes: [PredictionOutcome] = [],
    predictionWindow: Int,
    status: Status,
    createdAt: Date,
    endedAt: Date? = nil,
    lockedAt: Date? = nil
  ) {
    self.id = id
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.title = title
    self.winningOutcomeID = winningOutcomeID
    self.outcomes = outcomes
    self.predictionWindow = predictionWindow
    self.status = status
    self.createdAt = createdAt
    self.endedAt = endedAt
    self.lockedAt = lockedAt
  }

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

  /// The prediction’s wagering, lock, resolution, or cancellation state, preserving
  /// unfamiliar values in `rawValue`.
  public struct Status: RawRepresentable, Decodable, Sendable, Hashable {
    /// The exact status string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates a prediction status from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes a prediction status from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// The poll or prediction is accepting participation. Encoded as `"ACTIVE"`.
    public static let active = Self(rawValue: "ACTIVE")
    /// The prediction has a declared winning outcome. Encoded as `"RESOLVED"`.
    public static let resolved = Self(rawValue: "RESOLVED")
    /// The operation was cancelled. Encoded as `"CANCELED"`.
    public static let cancelled = Self(rawValue: "CANCELED")
    /// The prediction no longer accepts participation. Encoded as `"LOCKED"`.
    public static let locked = Self(rawValue: "LOCKED")
  }
}

/// A prediction outcome and its participating users and Channel Points totals.
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

  /// Creates a `PredictionOutcome` value.
  public init(
    id: String,
    title: String,
    users: Int,
    channelPoints: Int,
    topPredictors: [TopPredictor]? = nil,
    color: Color
  ) {
    self.id = id
    self.title = title
    self.users = users
    self.channelPoints = channelPoints
    self.topPredictors = topPredictors
    self.color = color
  }

  /// The display color assigned to a prediction outcome, preserving unfamiliar values in
  /// `rawValue`.
  public struct Color: RawRepresentable, Decodable, Sendable, Hashable {
    /// The exact color string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates an outcome color from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes an outcome color from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// The pink prediction outcome. Encoded as `"PINK"`.
    public static let pink = Self(rawValue: "PINK")
    /// The blue prediction outcome. Encoded as `"BLUE"`.
    public static let blue = Self(rawValue: "BLUE")
  }

  /// A leading viewer’s wager and winnings for a prediction outcome.
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

    /// Creates a `TopPredictor` value.
    public init(
      userID: String,
      userLogin: String,
      userDisplayName: String,
      channelPointsUsed: Int,
      channelPointsWon: Int? = nil
    ) {
      self.userID = userID
      self.userLogin = userLogin
      self.userDisplayName = userDisplayName
      self.channelPointsUsed = channelPointsUsed
      self.channelPointsWon = channelPointsWon
    }

    enum CodingKeys: String, CodingKey {
      case userID = "userId"
      case userLogin
      case userDisplayName = "userName"
      case channelPointsUsed
      case channelPointsWon
    }
  }
}

/// A page of predictions.
public struct PredictionsResponse: Sendable {
  /// The predictions on this page.
  public let predictions: [Prediction]
  /// The next-page cursor, if Twitch returned one.
  public let cursor: String?

  /// Creates a `PredictionsResponse` value.
  public init(
    predictions: [Prediction] = [],
    cursor: String? = nil
  ) {
    self.predictions = predictions
    self.cursor = cursor
  }
}
