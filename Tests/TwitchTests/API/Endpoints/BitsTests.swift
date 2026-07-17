import Foundation
import Testing

@testable import Twitch

struct BitsTests {
  private let harness = HelixTestHarness()

  @Test
  func getBitsLeaderboard() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/bits/leaderboard?count=2&period=week"))

    await harness.session.stub(
      url: url,
      body: MockedData.getBitsLeaderboardJSON)

    let leaderboard = try await harness.twitch.helix(
      endpoint: .getBitsLeaderboard(
        count: 2, period: .week,
        startedAt: nil))

    #expect(leaderboard.total == 2)
    #expect(leaderboard.leaders.count == 2)

    #expect(leaderboard.leaders.first?.userID == "158010205")
    #expect(leaderboard.leaders.first?.rank == 1)
    #expect(leaderboard.leaders.first?.score == 12543)

    #expect(leaderboard.startDate != nil)
    #expect(leaderboard.endDate != nil)
  }

  @Test
  func getCheermotes() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/bits/cheermotes"))

    await harness.session.stub(
      url: url,
      body: MockedData.getCheermotesJSON)

    let cheermotes = try await harness.twitch.helix(endpoint: .getCheermotes())

    #expect(cheermotes.count == 1)

    let cheermote = cheermotes.first
    #expect(cheermote?.prefix == "Cheer")
    #expect(cheermote?.type == "global_first_party")
    #expect(cheermote?.order == 1)
    #expect(cheermote?.lastUpdated.formatted(.iso8601) == "2018-05-22T00:06:04Z")
    #expect(cheermote?.isCharitable == false)

    let tier = cheermote?.tiers.first
    #expect(tier?.minBits == 1)
    #expect(tier?.id == "1")
    #expect(tier?.color == "#979797")
    #expect(tier?.canCheer == true)
    #expect(tier?.showInBitsCard == true)
    #expect(
      tier?.images.dark.animated.url1x
        == "https://d3aqoihi2n8ty8.cloudfront.net/actions/cheer/dark/animated/1/1.gif")
    #expect(
      tier?.images.light.staticImages.url2x
        == "https://d3aqoihi2n8ty8.cloudfront.net/actions/cheer/light/static/1/2.png")
  }

  @Test
  func getExtensionPredictions() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/extensions/predictions?extension_id=abcd1234&first=2&after=cursor"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getExtensionPredictionsJSON)

    let (predictions, cursor) = try await harness.twitch.helix(
      endpoint: .getExtensionPredictions(
        extensionID: "abcd1234", limit: 2, after: "cursor"))

    #expect(cursor == "eyJiIjpudWxsLCJhIjp7Ik9mZnNldCI6NX19")
    #expect(predictions.count == 1)

    let prediction = predictions.first
    #expect(prediction?.id == "d6676d5c-c86e-44d2-bfc4-100fb48f0656")
    #expect(prediction?.broadcasterID == "55696719")
    #expect(prediction?.broadcasterLogin == "twitchdev")
    #expect(prediction?.broadcasterName == "TwitchDev")
    #expect(prediction?.title == "Will there be any leaks today?")
    #expect(prediction?.predictionWindow == 600)
    #expect(prediction?.createdAt.formatted(.iso8601) == "2021-04-28T16:03:06Z")
    #expect(prediction?.endedAt == nil)

    let firstOutcome = prediction?.outcomes.first
    #expect(firstOutcome?.id == "021e9234-5893-49b4-982e-cfe9a0aaddd9")
    #expect(firstOutcome?.title == "Yes")
    #expect(firstOutcome?.users == 0)
    #expect(firstOutcome?.channelPoints == 0)
    #expect(firstOutcome?.color == .blue)
  }
}
