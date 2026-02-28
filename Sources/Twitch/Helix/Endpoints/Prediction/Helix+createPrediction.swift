import Foundation

extension HelixEndpoint {
  public static func createPrediction(
    title: String,
    outcomes: [String],
    predictionWindow: Int
  ) -> HelixEndpoint<Prediction, Prediction, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "predictions",
      body: { auth in
        CreatePredictionRequestBody(
          broadcasterID: auth.userID,
          title: title,
          outcomes: outcomes.map { .init(title: $0) },
          predictionWindow: predictionWindow)
      },
      makeResponse: {
        guard let prediction = $0.data.first else {
          throw HelixError.noDataInResponse(responseData: $0.rawData)
        }

        return prediction
      })
  }
}

internal struct CreatePredictionRequestBody: Encodable, Sendable {
  let broadcasterID: String
  let title: String
  let outcomes: [Outcome]
  let predictionWindow: Int

  struct Outcome: Encodable, Sendable {
    let title: String
  }
}
