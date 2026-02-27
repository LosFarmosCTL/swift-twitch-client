import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class EventSubTests: XCTestCase {
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

  func testGetEventSubSubscriptions() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getEventSubSubscriptionsJSON]
    ).register()

    let response = try await twitch.helix(endpoint: .getEventSubSubscriptions())

    XCTAssertEqual(response.total, 2)
    XCTAssertEqual(response.totalCost, 1)
    XCTAssertEqual(response.maxTotalCost, 10000)
    XCTAssertNil(response.cursor)

    XCTAssertEqual(response.subscriptions.count, 2)
    XCTAssertEqual(
      response.subscriptions.first?.id, "26b1c993-bfcf-44d9-b876-379dacafe75a")
    XCTAssertEqual(response.subscriptions.first?.status, "enabled")
    XCTAssertEqual(response.subscriptions.first?.type, "stream.online")
    XCTAssertEqual(response.subscriptions.first?.version, "1")
    XCTAssertEqual(response.subscriptions.first?.cost, 1)
    XCTAssertEqual(
      response.subscriptions.first?.condition["broadcaster_user_id"], "1234")

    XCTAssertEqual(
      response.subscriptions.last?.status, "webhook_callback_verification_pending")
    XCTAssertEqual(response.subscriptions.last?.type, "user.update")
    XCTAssertEqual(response.subscriptions.last?.cost, 0)
  }

  func testCreateEventSubSubscription() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.post: MockedData.createEventSubSubscriptionJSON]
    ).register()

    let response = try await twitch.helix(
      endpoint: .createEventSubSubscription(
        using: .webhook(callback: "https://this-is-a-callback.com", secret: "s3cre7"),
        type: .userUpdate(userID: "1234")))

    XCTAssertEqual(response.total, 1)
    XCTAssertEqual(response.totalCost, 1)
    XCTAssertEqual(response.maxTotalCost, 10000)

    XCTAssertEqual(response.subscription.id, "26b1c993-bfcf-44d9-b876-379dacafe75a")
    XCTAssertEqual(response.subscription.status, "webhook_callback_verification_pending")
    XCTAssertEqual(response.subscription.type, "user.update")
    XCTAssertEqual(response.subscription.version, "1")
    XCTAssertEqual(response.subscription.cost, 1)
    XCTAssertEqual(response.subscription.transport.method, "webhook")
    XCTAssertEqual(
      response.subscription.condition["user_id"], "1234")
  }

  func testDeleteEventSubSubscription() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/eventsub/subscriptions?id=26b1c993-bfcf-44d9-b876-379dacafe75a"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.helix(
      endpoint: .deleteEventSubSubscription(id: "26b1c993-bfcf-44d9-b876-379dacafe75a"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }
}
