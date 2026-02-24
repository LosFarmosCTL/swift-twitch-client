import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class HypeTrainTests: XCTestCase {
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

  func testGetHypeTrainStatus() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/hypetrain/status?broadcaster_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getHypeTrainStatusJSON]
    ).register()

    let status = try await twitch.helix(endpoint: .getHypeTrainStatus())

    XCTAssertEqual(status.current?.id, "1b0AsbInCHZW2SQFQkCzqN07Ib2")
    XCTAssertEqual(status.current?.broadcasterID, "1337")
    XCTAssertEqual(status.current?.broadcasterLogin, "cool_user")
    XCTAssertEqual(status.current?.broadcasterName, "Cool_User")
    XCTAssertEqual(status.current?.level, 2)
    XCTAssertEqual(status.current?.total, 700)
    XCTAssertEqual(status.current?.progress, 200)
    XCTAssertEqual(status.current?.goal, 1000)
    XCTAssertEqual(status.current?.type, .goldenKappa)
    XCTAssertEqual(status.current?.isSharedTrain, true)
    XCTAssertEqual(status.current?.topContributions.count, 2)
    XCTAssertEqual(status.current?.topContributions.first?.type, .bits)
    XCTAssertEqual(status.current?.topContributions.first?.total, 50)
    XCTAssertEqual(status.current?.sharedTrainParticipants?.count, 2)
    XCTAssertEqual(
      status.current?.startedAt.formatted(.iso8601), "2020-07-15T17:16:03Z")
    XCTAssertEqual(
      status.current?.expiresAt.formatted(.iso8601), "2020-07-15T17:16:11Z")
    XCTAssertEqual(status.allTimeHigh?.level, 6)
    XCTAssertEqual(status.allTimeHigh?.total, 2850)
    XCTAssertEqual(
      status.allTimeHigh?.achievedAt.formatted(.iso8601), "2020-04-24T20:12:21Z")
    XCTAssertEqual(status.sharedAllTimeHigh?.level, 16)
    XCTAssertEqual(status.sharedAllTimeHigh?.total, 23850)
    XCTAssertEqual(
      status.sharedAllTimeHigh?.achievedAt.formatted(.iso8601), "2020-04-27T20:12:21Z")
  }
}
