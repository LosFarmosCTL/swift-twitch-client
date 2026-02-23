import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class AnalyticsTests: XCTestCase {
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

  func testGetExtensionAnalytics() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/analytics/extensions")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getExtensionAnalyticsJSON]
    ).register()

    let (analytics, _) = try await twitch.helix(endpoint: .getExtensionAnalytics())

    XCTAssertEqual(analytics.count, 1)
    XCTAssert(analytics.contains(where: { $0.extensionID == "efgh" }))

    XCTAssertEqual(
      analytics.first?.range.start.formatted(.iso8601), "2018-03-01T00:00:00Z")
    XCTAssertEqual(analytics.first?.range.end.formatted(.iso8601), "2018-06-01T00:00:00Z")
  }

  func testGetGameAnalytics() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/analytics/games")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getGameAnalyticsJSON]
    ).register()

    let (analytics, _) = try await twitch.helix(endpoint: .getGameAnalytics())

    XCTAssertEqual(analytics.count, 1)

    XCTAssert(analytics.contains(where: { $0.gameID == "9821" }))

    XCTAssertEqual(
      analytics.first?.range.start.formatted(.iso8601), "2018-03-13T00:00:00Z")
    XCTAssertEqual(analytics.first?.range.end.formatted(.iso8601), "2018-06-13T00:00:00Z")
  }
}
