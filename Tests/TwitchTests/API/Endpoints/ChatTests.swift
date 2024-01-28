import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class ChatTests: XCTestCase {
  private var helix: Helix!

  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    let urlSession = URLSession(configuration: configuration)

    helix = try Helix(
      authentication: .init(oAuth: "1234567989", clientID: "abcdefghijkl"),
      urlSession: urlSession)
  }

  func testGetChatters() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/chat/chatters?broadcaster_id=123&moderator_id=456")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getChattersJSON]
    ).register()

    let (total, analytics, cursor) = try await helix.getChatters(
      broadcasterId: "123", moderatorId: "456")

    XCTAssertEqual(analytics.count, 1)
    XCTAssertEqual(total, 8)
    XCTAssertEqual(cursor, "eyJiIjpudWxsLCJhIjp7Ik9mZnNldCI6NX19")

    XCTAssert(analytics.contains(where: { $0.userId == "128393656" }))
  }

  func testGameAnalytics() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/analytics/games")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getGameAnalyticsJSON]
    ).register()

    let (analytics, _) = try await helix.getGameAnalytics()

    XCTAssertEqual(analytics.count, 1)

    XCTAssert(analytics.contains(where: { $0.gameId == "9821" }))

    XCTAssertEqual(
      analytics.first?.range.start.formatted(.iso8601), "2018-03-13T00:00:00Z")
    XCTAssertEqual(analytics.first?.range.end.formatted(.iso8601), "2018-06-13T00:00:00Z")
  }
}
