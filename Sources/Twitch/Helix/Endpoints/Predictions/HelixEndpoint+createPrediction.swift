import Foundation

extension HelixEndpoint {
  /// Starts a prediction in the authenticated broadcaster’s channel.
  ///
  /// With a user access token, requires `channel:manage:predictions`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#create-prediction
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - title: The title shown to viewers.
  ///   - outcomes: The titles of the prediction outcomes.
  ///   - predictionWindow: The prediction voting window, in seconds.
  public static func createPrediction(
    title: String,
    outcomes: [String],
    predictionWindow: Int
  ) -> HelixEndpoint<Prediction, Prediction, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "predictions",
      authentication: .user,
      body: { credentials in
        CreatePredictionRequestBody(
          broadcasterID: try credentials.requireUser().id,
          title: title,
          outcomes: outcomes.map { .init(title: $0) },
          predictionWindow: predictionWindow)
      },
      makeResponse: {
        let prediction = try $0.requireFirst()

        return prediction
      })
  }
}

private struct CreatePredictionRequestBody: Encodable, Sendable {
  let broadcasterID: String
  let title: String
  let outcomes: [Outcome]
  let predictionWindow: Int

  struct Outcome: Encodable, Sendable {
    let title: String
  }
}
