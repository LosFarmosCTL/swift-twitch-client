import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class BitsTests: XCTestCase {
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

  func testGetBitsLeaderboard() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/bits/leaderboard?count=2&period=week")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getBitsLeaderboardJSON]
    ).register()

    let leaderboard = try await twitch.helix(
      endpoint: .getBitsLeaderboard(
        count: 2, period: .week,
        startedAt: nil))

    XCTAssertEqual(leaderboard.total, 2)
    XCTAssertEqual(leaderboard.leaders.count, 2)

    XCTAssertEqual(leaderboard.leaders.first?.userID, "158010205")
    XCTAssertEqual(leaderboard.leaders.first?.rank, 1)
    XCTAssertEqual(leaderboard.leaders.first?.score, 12543)

    XCTAssertNotNil(leaderboard.startDate)
    XCTAssertNotNil(leaderboard.endDate)
  }

  func testGetCheermotes() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/bits/cheermotes")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getCheermotesJSON]
    ).register()

    let cheermotes = try await twitch.helix(endpoint: .getCheermotes())

    XCTAssertEqual(cheermotes.count, 1)

    let cheermote = cheermotes.first
    XCTAssertEqual(cheermote?.prefix, "Cheer")
    XCTAssertEqual(cheermote?.type, "global_first_party")
    XCTAssertEqual(cheermote?.order, 1)
    XCTAssertEqual(cheermote?.lastUpdated.formatted(.iso8601), "2018-05-22T00:06:04Z")
    XCTAssertEqual(cheermote?.isCharitable, false)

    let tier = cheermote?.tiers.first
    XCTAssertEqual(tier?.minBits, 1)
    XCTAssertEqual(tier?.id, "1")
    XCTAssertEqual(tier?.color, "#979797")
    XCTAssertEqual(tier?.canCheer, true)
    XCTAssertEqual(tier?.showInBitsCard, true)
    XCTAssertEqual(
      tier?.images.dark.animated.url1x,
      "https://d3aqoihi2n8ty8.cloudfront.net/actions/cheer/dark/animated/1/1.gif")
    XCTAssertEqual(
      tier?.images.light.staticImages.url2x,
      "https://d3aqoihi2n8ty8.cloudfront.net/actions/cheer/light/static/1/2.png")
  }

  func testGetExtensionPredictions() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/extensions/predictions?extension_id=abcd1234&first=2&after=cursor"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getExtensionPredictionsJSON]
    ).register()

    let (predictions, cursor) = try await twitch.helix(
      endpoint: .getExtensionPredictions(
        extensionID: "abcd1234", limit: 2, after: "cursor"))

    XCTAssertEqual(cursor, "eyJiIjpudWxsLCJhIjp7Ik9mZnNldCI6NX19")
    XCTAssertEqual(predictions.count, 1)

    let prediction = predictions.first
    XCTAssertEqual(prediction?.id, "d6676d5c-c86e-44d2-bfc4-100fb48f0656")
    XCTAssertEqual(prediction?.broadcasterID, "55696719")
    XCTAssertEqual(prediction?.broadcasterLogin, "twitchdev")
    XCTAssertEqual(prediction?.broadcasterName, "TwitchDev")
    XCTAssertEqual(prediction?.title, "Will there be any leaks today?")
    XCTAssertEqual(prediction?.predictionWindow, 600)
    XCTAssertEqual(
      prediction?.createdAt.formatted(.iso8601), "2021-04-28T16:03:06Z")
    XCTAssertNil(prediction?.endedAt)

    let firstOutcome = prediction?.outcomes.first
    XCTAssertEqual(firstOutcome?.id, "021e9234-5893-49b4-982e-cfe9a0aaddd9")
    XCTAssertEqual(firstOutcome?.title, "Yes")
    XCTAssertEqual(firstOutcome?.users, 0)
    XCTAssertEqual(firstOutcome?.channelPoints, 0)
    XCTAssertEqual(firstOutcome?.color, .blue)
  }
}
