import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class PredictionTests: XCTestCase {
  private var twitch: TwitchClient!

  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    let urlSession = URLSession(configuration: configuration)

    twitch = TwitchClient(
      authentication: .init(
        oAuth: "1234567989", clientID: "abcdefghijkl", userID: "1234", userLogin: "user"),
      urlSession: urlSession)
  }

  func testGetPredictions() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/predictions?broadcaster_id=1234&id=d6676d5c-c86e-44d2-bfc4-100fb48f0656"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getPredictionsJSON]
    ).register()

    let (predictions, cursor) = try await twitch.helix(
      endpoint: .getPredictions(
        filterIDs: ["d6676d5c-c86e-44d2-bfc4-100fb48f0656"],
        limit: nil,
        after: nil)
    )

    XCTAssertNil(cursor)
    XCTAssertEqual(predictions.count, 1)

    let prediction = predictions[0]
    XCTAssertEqual(prediction.id, "d6676d5c-c86e-44d2-bfc4-100fb48f0656")
    XCTAssertEqual(prediction.broadcasterID, "55696719")
    XCTAssertEqual(prediction.broadcasterLogin, "twitchdev")
    XCTAssertEqual(prediction.broadcasterName, "TwitchDev")
    XCTAssertEqual(prediction.title, "Will there be any leaks today?")
    XCTAssertNil(prediction.winningOutcomeID)
    XCTAssertEqual(prediction.predictionWindow, 600)
    XCTAssertEqual(prediction.status, .active)
    XCTAssertEqual(
      prediction.createdAt.formatted(.iso8601), "2021-04-28T16:03:06Z")
    XCTAssertNil(prediction.endedAt)
    XCTAssertNil(prediction.lockedAt)

    XCTAssertEqual(prediction.outcomes.count, 2)
    XCTAssertEqual(prediction.outcomes[0].id, "021e9234-5893-49b4-982e-cfe9a0aaddd9")
    XCTAssertEqual(prediction.outcomes[0].title, "Yes")
    XCTAssertEqual(prediction.outcomes[0].users, 0)
    XCTAssertEqual(prediction.outcomes[0].channelPoints, 0)
    XCTAssertNil(prediction.outcomes[0].topPredictors)
    XCTAssertEqual(prediction.outcomes[0].color, .blue)
  }

  func testCreatePrediction() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/predictions")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.post: MockedData.createPredictionJSON]
    ).register()

    let prediction = try await twitch.helix(
      endpoint: .createPrediction(
        title: "Any leeks in the stream?",
        outcomes: ["Yes, give it time.", "Definitely not."],
        predictionWindow: 120))

    XCTAssertEqual(prediction.id, "bc637af0-7766-4525-9308-4112f4cbf178")
    XCTAssertEqual(prediction.broadcasterID, "141981764")
    XCTAssertEqual(prediction.broadcasterLogin, "twitchdev")
    XCTAssertEqual(prediction.broadcasterName, "TwitchDev")
    XCTAssertEqual(prediction.title, "Any leeks in the stream?")
    XCTAssertNil(prediction.winningOutcomeID)
    XCTAssertEqual(prediction.predictionWindow, 120)
    XCTAssertEqual(prediction.status, .active)
    XCTAssertEqual(
      prediction.createdAt.formatted(.iso8601), "2021-04-28T17:11:22Z")
    XCTAssertNil(prediction.endedAt)
    XCTAssertNil(prediction.lockedAt)

    XCTAssertEqual(prediction.outcomes.count, 2)
    XCTAssertEqual(prediction.outcomes[0].id, "73085848-a94d-4040-9d21-2cb7a89374b7")
    XCTAssertEqual(prediction.outcomes[0].title, "Yes, give it time.")
    XCTAssertEqual(prediction.outcomes[0].users, 0)
    XCTAssertEqual(prediction.outcomes[0].channelPoints, 0)
    XCTAssertNil(prediction.outcomes[0].topPredictors)
    XCTAssertEqual(prediction.outcomes[0].color, .blue)
  }

  func testEndPrediction() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/predictions?broadcaster_id=1234&id=bc637af0-7766-4525-9308-4112f4cbf178&status=RESOLVED&winning_outcome_id=73085848-a94d-4040-9d21-2cb7a89374b7"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.patch: MockedData.endPredictionJSON]
    ).register()

    let prediction = try await twitch.helix(
      endpoint: .endPrediction(
        predictionID: "bc637af0-7766-4525-9308-4112f4cbf178",
        status: .resolved,
        winningOutcomeID: "73085848-a94d-4040-9d21-2cb7a89374b7"))

    XCTAssertEqual(prediction.id, "bc637af0-7766-4525-9308-4112f4cbf178")
    XCTAssertEqual(prediction.broadcasterID, "141981764")
    XCTAssertEqual(prediction.broadcasterLogin, "twitchdev")
    XCTAssertEqual(prediction.broadcasterName, "TwitchDev")
    XCTAssertEqual(prediction.title, "Will we win all the games?")
    XCTAssertEqual(
      prediction.winningOutcomeID, "73085848-a94d-4040-9d21-2cb7a89374b7")
    XCTAssertEqual(prediction.predictionWindow, 120)
    XCTAssertEqual(prediction.status, .resolved)
    XCTAssertEqual(
      prediction.createdAt.formatted(.iso8601), "2021-04-28T21:48:19Z")
    XCTAssertEqual(
      prediction.endedAt?.formatted(.iso8601), "2021-04-28T21:54:24Z")
    XCTAssertEqual(
      prediction.lockedAt?.formatted(.iso8601), "2021-04-28T21:48:34Z")

    XCTAssertEqual(prediction.outcomes.count, 2)
    XCTAssertEqual(prediction.outcomes[0].id, "73085848-a94d-4040-9d21-2cb7a89374b7")
    XCTAssertEqual(prediction.outcomes[0].title, "yes")
    XCTAssertEqual(prediction.outcomes[0].users, 0)
    XCTAssertEqual(prediction.outcomes[0].channelPoints, 0)
    XCTAssertNil(prediction.outcomes[0].topPredictors)
    XCTAssertEqual(prediction.outcomes[0].color, .blue)
  }
}
