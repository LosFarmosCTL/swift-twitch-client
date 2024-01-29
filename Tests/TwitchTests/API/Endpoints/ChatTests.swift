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
}
