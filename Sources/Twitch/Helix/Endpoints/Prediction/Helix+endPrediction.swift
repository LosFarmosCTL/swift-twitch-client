import Foundation

extension HelixEndpoint {
  public static func endPrediction(
    predictionID: String,
    status: PredictionEndStatus,
    winningOutcomeID: String? = nil
  ) -> HelixEndpoint<Prediction, Prediction, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "PATCH", path: "predictions",
      queryItems: { auth in
        [
          ("broadcaster_id", auth.userID),
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

public enum PredictionEndStatus: String, Sendable {
  case resolved = "RESOLVED"
  case canceled = "CANCELED"
  case locked = "LOCKED"
}
