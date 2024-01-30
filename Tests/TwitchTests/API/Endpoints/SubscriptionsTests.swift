import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class SubscriptionsTests: XCTestCase {
  private var helix: Helix!

  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    let urlSession = URLSession(configuration: configuration)

    helix = try Helix(
      authentication: .init(
        oAuth: "1234567989", clientID: "abcdefghijkl", userId: "1234"),
      urlSession: urlSession)
  }

  func testGetBroadcasterSubscribers() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/subscriptions?broadcaster_id=1234&first=2")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getBroadcasterSubscriptionsJSON]
    ).register()

    let ((total, points), subscribers, cursor) =
      try await helix.getBroadcasterSubscribers(limit: 2)

    XCTAssertEqual(total, 13)
    XCTAssertEqual(points, 13)

    XCTAssertEqual(cursor, "jnksdfyg7is8do7fv7yuwbisudg")

    XCTAssertEqual(subscribers.count, 2)
    XCTAssertNotNil(subscribers.first?.gifter)
    XCTAssertEqual(subscribers.first?.gifter?.id, "12826")
    XCTAssertEqual(subscribers.first?.gifter?.login, "twitch")
    XCTAssertEqual(subscribers.first?.gifter?.name, "Twitch")
    XCTAssertNil(subscribers.last?.gifter)
  }

  func testCheckUserSubscription() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/subscriptions/user?broadcaster_id=1234&user_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.checkUserSubscriptionJSON]
    ).register()

    let subscription = try await helix.checkUserSubscription(to: "1234")

    XCTAssertEqual(subscription?.broadcasterId, "141981764")
    XCTAssertEqual(subscription?.gifter?.id, "12826")
  }
}
