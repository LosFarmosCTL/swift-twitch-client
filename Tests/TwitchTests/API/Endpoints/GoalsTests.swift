import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class GoalsTests: XCTestCase {
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

  func testGetCreatorGoals() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/goals?broadcaster_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getCreatorGoalsJSON]
    ).register()

    let goals = try await twitch.helix(endpoint: .getCreatorGoals())

    XCTAssertEqual(goals.count, 1)
    XCTAssertEqual(goals.first?.id, "1woowvbkiNv8BRxEWSqmQz6Zk92")
    XCTAssertEqual(goals.first?.broadcasterID, "141981764")
    XCTAssertEqual(goals.first?.broadcasterName, "TwitchDev")
    XCTAssertEqual(goals.first?.broadcasterLogin, "twitchdev")
    XCTAssertEqual(goals.first?.type, .follower)
    XCTAssertEqual(goals.first?.description, "Follow goal for Helix testing")
    XCTAssertEqual(goals.first?.currentAmount, 27062)
    XCTAssertEqual(goals.first?.targetAmount, 30000)
    XCTAssertEqual(goals.first?.createdAt.formatted(.iso8601), "2021-08-16T17:22:23Z")
  }
}
