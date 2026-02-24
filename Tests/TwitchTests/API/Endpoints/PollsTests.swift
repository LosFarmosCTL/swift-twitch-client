import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class PollsTests: XCTestCase {
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

  func testGetPolls() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/polls?broadcaster_id=1234&id=ed961efd-8a3f-4cf5-a9d0-e616c590cd2a"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getPollsJSON]
    ).register()

    let (polls, cursor) = try await twitch.helix(
      endpoint: .getPolls(filterIDs: ["ed961efd-8a3f-4cf5-a9d0-e616c590cd2a"]))

    XCTAssertEqual(polls.count, 1)
    XCTAssertNil(cursor)

    let poll = polls.first
    XCTAssertEqual(poll?.id, "ed961efd-8a3f-4cf5-a9d0-e616c590cd2a")
    XCTAssertEqual(poll?.broadcasterID, "55696719")
    XCTAssertEqual(poll?.title, "Heads or Tails?")
    XCTAssertEqual(poll?.choices.count, 2)
    XCTAssertEqual(poll?.choices.first?.title, "Heads")
    XCTAssertEqual(poll?.status, .active)
    XCTAssertEqual(poll?.duration, 1800)
    XCTAssertEqual(
      poll?.startedAt.formatted(.iso8601), "2021-03-19T06:08:33Z")
    XCTAssertNil(poll?.endedAt)
  }

  func testCreatePoll() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/polls")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.post: MockedData.createPollJSON]
    ).register()

    let poll = try await twitch.helix(
      endpoint: .createPoll(
        title: "Heads or Tails?",
        choices: ["Heads", "Tails"],
        duration: 1800,
        channelPointsVotingEnabled: true,
        channelPointsPerVote: 100))

    XCTAssertEqual(poll.id, "ed961efd-8a3f-4cf5-a9d0-e616c590cd2a")
    XCTAssertEqual(poll.broadcasterID, "141981764")
    XCTAssertEqual(poll.channelPointsVotingEnabled, true)
    XCTAssertEqual(poll.channelPointsPerVote, 100)
    XCTAssertEqual(poll.status, .active)
  }

  func testEndPoll() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/polls")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.patch: MockedData.endPollJSON]
    ).register()

    let poll = try await twitch.helix(
      endpoint: .endPoll(
        id: "ed961efd-8a3f-4cf5-a9d0-e616c590cd2a",
        status: .terminated))

    XCTAssertEqual(poll.id, "ed961efd-8a3f-4cf5-a9d0-e616c590cd2a")
    XCTAssertEqual(poll.status, .terminated)
    XCTAssertEqual(
      poll.endedAt?.formatted(.iso8601), "2021-03-19T06:11:26Z")
  }
}
