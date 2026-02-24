import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class ConduitsTests: XCTestCase {
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

  func testGetConduits() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/eventsub/conduits")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getConduitsJSON]
    ).register()

    let conduits = try await twitch.helix(endpoint: .getConduits())

    XCTAssertEqual(conduits.count, 2)
    XCTAssertEqual(conduits.first?.id, "26b1c993-bfcf-44d9-b876-379dacafe75a")
    XCTAssertEqual(conduits.first?.shardCount, 15)
  }

  func testCreateConduit() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/eventsub/conduits")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.post: MockedData.createConduitJSON]
    ).register()

    let conduit = try await twitch.helix(endpoint: .createConduit(shardCount: 5))

    XCTAssertEqual(conduit.id, "bfcfc993-26b1-b876-44d9-afe75a379dac")
    XCTAssertEqual(conduit.shardCount, 5)
  }

  func testUpdateConduit() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/eventsub/conduits")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.patch: MockedData.updateConduitJSON]
    ).register()

    let conduit = try await twitch.helix(
      endpoint: .updateConduit(id: "bfcfc993-26b1-b876-44d9-afe75a379dac", shardCount: 5))

    XCTAssertEqual(conduit.id, "bfcfc993-26b1-b876-44d9-afe75a379dac")
    XCTAssertEqual(conduit.shardCount, 5)
  }

  func testDeleteConduit() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/eventsub/conduits?id=bfcfc993-26b1-b876-44d9-afe75a379dac"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.helix(
      endpoint: .deleteConduit(id: "bfcfc993-26b1-b876-44d9-afe75a379dac"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testGetConduitShards() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/eventsub/conduits/shards?conduit_id=bfcfc993-26b1-b876-44d9-afe75a379dac"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getConduitShardsJSON]
    ).register()

    let (shards, cursor) = try await twitch.helix(
      endpoint: .getConduitShards(conduitID: "bfcfc993-26b1-b876-44d9-afe75a379dac"))

    XCTAssertNil(cursor)
    XCTAssertEqual(shards.count, 5)
    XCTAssertEqual(shards[0].id, "0")
    XCTAssertEqual(shards[0].status, "enabled")
    XCTAssertEqual(shards[0].transport.method, "webhook")
    XCTAssertEqual(shards[0].transport.callback, "https://this-is-a-callback.com")
    XCTAssertNil(shards[0].transport.sessionID)

    XCTAssertEqual(shards[2].transport.method, "websocket")
    XCTAssertEqual(shards[2].transport.sessionID, "9fd5164a-a958-4c60-b7f4-6a7202506ca0")
    XCTAssertNotNil(shards[2].transport.connectedAt)

    XCTAssertEqual(shards[4].status, "websocket_disconnected")
    XCTAssertNotNil(shards[4].transport.disconnectedAt)
  }

  func testUpdateConduitShards() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/eventsub/conduits/shards")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.patch: MockedData.updateConduitShardsJSON]
    ).register()

    let response = try await twitch.helix(
      endpoint: .updateConduitShards(
        conduitID: "bfcfc993-26b1-b876-44d9-afe75a379dac",
        shards: [
          .init(
            id: "0",
            transport: .webhook(
              callback: "https://this-is-a-callback.com", secret: "s3cre7")),
          .init(
            id: "1",
            transport: .webhook(
              callback: "https://this-is-a-callback-2.com", secret: "s3cre7")),
        ]))

    XCTAssertEqual(response.shards.count, 2)
    XCTAssertEqual(response.shards.first?.id, "0")
    XCTAssertEqual(response.shards.first?.status, "enabled")
    XCTAssertEqual(
      response.shards.first?.transport.callback, "https://this-is-a-callback.com")

    XCTAssertEqual(response.errors.count, 1)
    XCTAssertEqual(response.errors.first?.id, "3")
    XCTAssertEqual(response.errors.first?.code, "invalid_parameter")
  }
}
