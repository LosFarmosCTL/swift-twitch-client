import Foundation

extension HelixEndpoint {
  /// Locks, resolves, or cancels a prediction.
  ///
  /// With a user access token, requires `channel:manage:predictions`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#end-prediction
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - predictionID: The identifier of the prediction.
  ///   - status: The requested status or status filter.
  ///   - winningOutcomeID: The outcome to declare the winner when resolving the
  ///     prediction.
  public static func endPrediction(
    predictionID: String,
    status: PredictionEndStatus,
    winningOutcomeID: String? = nil
  ) -> HelixEndpoint<Prediction, Prediction, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "PATCH", path: "predictions",
      queryItems: { credentials in
        [
          ("broadcaster_id", credentials.userID),
          ("id", predictionID),
          ("status", status.rawValue),
          ("winning_outcome_id", winningOutcomeID),
        ]
      },
      makeResponse: {
        let prediction = try $0.requireFirst()

        return prediction
      })
  }
}

/// The requested transition to lock, resolve, or cancel a prediction.
public enum PredictionEndStatus: String, Sendable {
  /// Resolves the prediction using the specified winning outcome. Encoded as
  /// `"RESOLVED"`.
  case resolved = "RESOLVED"
  /// Cancels the prediction and refunds Channel Points. Encoded as `"CANCELED"`.
  case cancelled = "CANCELED"
  /// Locks the prediction against further participation. Encoded as `"LOCKED"`.
  case locked = "LOCKED"
}
