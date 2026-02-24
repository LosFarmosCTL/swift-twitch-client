import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class EntitlementsTests: XCTestCase {
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

  func testGetDropsEntitlements() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/entitlements/drops?user_id=25009227&game_id=33214&first=3"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getDropsEntitlementsJSON]
    ).register()

    let (entitlements, cursor) = try await twitch.helix(
      endpoint: .getDropsEntitlements(
        userID: "25009227", gameID: "33214", limit: 3))

    XCTAssertEqual(cursor, "eyJiIjpudWxsLCJhIjp7IkN1cnNvciI6MX0")

    XCTAssertEqual(entitlements.count, 3)
    let first = try XCTUnwrap(entitlements.first)
    XCTAssertEqual(first.id, "fb78259e-fb81-4d1b-8333-34a06ffc24c0")
    XCTAssertEqual(first.benefitID, "74c52265-e214-48a6-91b9-23b6014e8041")
    XCTAssertEqual(first.userID, "25009227")
    XCTAssertEqual(first.gameID, "33214")
    XCTAssertEqual(first.fulfillmentStatus, .claimed)
    XCTAssertEqual(
      first.timestamp.formatted(.iso8601), "2019-01-28T04:17:53Z")
    XCTAssertEqual(
      first.lastUpdated.formatted(.iso8601), "2019-01-28T04:17:53Z")
  }

  func testUpdateDropsEntitlements() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/entitlements/drops")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.patch: MockedData.updateDropsEntitlementsJSON]
    ).register()

    let results = try await twitch.helix(
      endpoint: .updateDropsEntitlements(
        entitlementIDs: [
          "fb78259e-fb81-4d1b-8333-34a06ffc24c0",
          "862750a5-265e-4ab6-9f0a-c64df3d54dd0",
          "d8879baa-3966-4d10-8856-15fdd62cce02",
          "9a290126-7e3b-4f66-a9ae-551537893b65",
        ],
        fulfillmentStatus: .fulfilled))

    XCTAssertEqual(results.count, 3)
    XCTAssertEqual(results.first?.status, .success)
    XCTAssertEqual(results.first?.ids.count, 2)
    XCTAssertEqual(results[1].status, .unauthorized)
    XCTAssertEqual(results[1].ids, ["d8879baa-3966-4d10-8856-15fdd62cce02"])
    XCTAssertEqual(results[2].status, .updateFailed)
    XCTAssertEqual(results[2].ids, ["9a290126-7e3b-4f66-a9ae-551537893b65"])
  }
}
