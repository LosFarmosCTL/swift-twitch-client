import Foundation
import Testing

@testable import Twitch

struct PredictionTests {
  private let harness = HelixTestHarness()

  @Test
  func getPredictions() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/predictions?broadcaster_id=1234&id=d6676d5c-c86e-44d2-bfc4-100fb48f0656"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getPredictionsJSON)

    let (predictions, cursor) = try await harness.twitch.helix(
      endpoint: .getPredictions(
        filterIDs: ["d6676d5c-c86e-44d2-bfc4-100fb48f0656"],
        limit: nil,
        after: nil)
    )

    #expect(cursor == nil)
    #expect(predictions.count == 1)

    let prediction = predictions[0]
    #expect(prediction.id == "d6676d5c-c86e-44d2-bfc4-100fb48f0656")
    #expect(prediction.broadcasterID == "55696719")
    #expect(prediction.broadcasterLogin == "twitchdev")
    #expect(prediction.broadcasterName == "TwitchDev")
    #expect(prediction.title == "Will there be any leaks today?")
    #expect(prediction.winningOutcomeID == nil)
    #expect(prediction.predictionWindow == 600)
    #expect(prediction.status == .active)
    #expect(prediction.createdAt.formatted(.iso8601) == "2021-04-28T16:03:06Z")
    #expect(prediction.endedAt == nil)
    #expect(prediction.lockedAt == nil)

    #expect(prediction.outcomes.count == 2)
    #expect(prediction.outcomes[0].id == "021e9234-5893-49b4-982e-cfe9a0aaddd9")
    #expect(prediction.outcomes[0].title == "Yes")
    #expect(prediction.outcomes[0].users == 0)
    #expect(prediction.outcomes[0].channelPoints == 0)
    #expect(prediction.outcomes[0].topPredictors == nil)
    #expect(prediction.outcomes[0].color == .blue)
  }

  @Test
  func createPrediction() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/predictions"))

    await harness.session.stub(
      url: url,
      method: "POST",
      body: MockedData.createPredictionJSON)

    let prediction = try await harness.twitch.helix(
      endpoint: .createPrediction(
        title: "Any leeks in the stream?",
        outcomes: ["Yes, give it time.", "Definitely not."],
        predictionWindow: 120))

    #expect(prediction.id == "bc637af0-7766-4525-9308-4112f4cbf178")
    #expect(prediction.broadcasterID == "141981764")
    #expect(prediction.broadcasterLogin == "twitchdev")
    #expect(prediction.broadcasterName == "TwitchDev")
    #expect(prediction.title == "Any leeks in the stream?")
    #expect(prediction.winningOutcomeID == nil)
    #expect(prediction.predictionWindow == 120)
    #expect(prediction.status == .active)
    #expect(prediction.createdAt.formatted(.iso8601) == "2021-04-28T17:11:22Z")
    #expect(prediction.endedAt == nil)
    #expect(prediction.lockedAt == nil)

    #expect(prediction.outcomes.count == 2)
    #expect(prediction.outcomes[0].id == "73085848-a94d-4040-9d21-2cb7a89374b7")
    #expect(prediction.outcomes[0].title == "Yes, give it time.")
    #expect(prediction.outcomes[0].users == 0)
    #expect(prediction.outcomes[0].channelPoints == 0)
    #expect(prediction.outcomes[0].topPredictors == nil)
    #expect(prediction.outcomes[0].color == .blue)
  }

  @Test
  func endPrediction() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/predictions?broadcaster_id=1234&id=bc637af0-7766-4525-9308-4112f4cbf178&status=RESOLVED&winning_outcome_id=73085848-a94d-4040-9d21-2cb7a89374b7"
      ))

    await harness.session.stub(
      url: url,
      method: "PATCH",
      body: MockedData.endPredictionJSON)

    let prediction = try await harness.twitch.helix(
      endpoint: .endPrediction(
        predictionID: "bc637af0-7766-4525-9308-4112f4cbf178",
        status: .resolved,
        winningOutcomeID: "73085848-a94d-4040-9d21-2cb7a89374b7"))

    #expect(prediction.id == "bc637af0-7766-4525-9308-4112f4cbf178")
    #expect(prediction.broadcasterID == "141981764")
    #expect(prediction.broadcasterLogin == "twitchdev")
    #expect(prediction.broadcasterName == "TwitchDev")
    #expect(prediction.title == "Will we win all the games?")
    #expect(prediction.winningOutcomeID == "73085848-a94d-4040-9d21-2cb7a89374b7")
    #expect(prediction.predictionWindow == 120)
    #expect(prediction.status == .resolved)
    #expect(prediction.createdAt.formatted(.iso8601) == "2021-04-28T21:48:19Z")
    #expect(prediction.endedAt?.formatted(.iso8601) == "2021-04-28T21:54:24Z")
    #expect(prediction.lockedAt?.formatted(.iso8601) == "2021-04-28T21:48:34Z")

    #expect(prediction.outcomes.count == 2)
    #expect(prediction.outcomes[0].id == "73085848-a94d-4040-9d21-2cb7a89374b7")
    #expect(prediction.outcomes[0].title == "yes")
    #expect(prediction.outcomes[0].users == 0)
    #expect(prediction.outcomes[0].channelPoints == 0)
    #expect(prediction.outcomes[0].topPredictors == nil)
    #expect(prediction.outcomes[0].color == .blue)
  }
}
