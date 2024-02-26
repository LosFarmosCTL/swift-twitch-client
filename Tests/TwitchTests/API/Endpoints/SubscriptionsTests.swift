import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class SubscriptionsTests: XCTestCase {
  private var twitch: TwitchClient!

  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    let urlSession = URLSession(configuration: configuration)

    twitch = try TwitchClient(
      authentication: .init(
        oAuth: "1234567989", clientID: "abcdefghijkl", userID: "1234", userLogin: "user"),
      urlSession: urlSession)
  }

  func testGetBroadcasterSubscribers() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/subscriptions?broadcaster_id=1234&first=2")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getBroadcasterSubscriptionsJSON]
    ).register()

    let result = try await twitch.request(
      endpoint: .getSubscribers(of: "1234", limit: 2))
    let subscribers = result.data

    XCTAssertEqual(result.total, 13)
    XCTAssertEqual(result.points, 13)

    XCTAssertEqual(result.pagination?.cursor, "jnksdfyg7is8do7fv7yuwbisudg")

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

    let subscription = try await twitch.request(
      endpoint: .checkSubscription(of: "1234", to: "1234"))

    XCTAssertEqual(subscription?.broadcasterID, "141981764")
    XCTAssertEqual(subscription?.gifter?.id, "12826")
  }
}
