import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class AnalyticsTests: XCTestCase {
  private var helix: Helix!

  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    let urlSession = URLSession(configuration: configuration)

    helix = try Helix(
      authentication: .init(oAuth: "1234567989", clientID: "abcdefghijkl"),
      urlSession: urlSession)
  }

  func testGetExtensionAnalytics() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/analytics/extensions")!

    Mock(
      url: url, dataType: .json, statusCode: 200,
      data: [.get: MockedData.getExtensionAnalyticsJSON]
    ).register()

    let (analytics, _) = try await helix.getExtensionAnalytics()

    XCTAssertEqual(analytics.count, 1)
    XCTAssert(analytics.contains(where: { $0.extensionId == "efgh" }))

    XCTAssertEqual(analytics.first?.range.start.ISO8601Format(), "2018-03-01T00:00:00Z")
    XCTAssertEqual(analytics.first?.range.end.ISO8601Format(), "2018-06-01T00:00:00Z")
  }

  func testGameAnalytics() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/analytics/games")!

    Mock(
      url: url, dataType: .json, statusCode: 200,
      data: [.get: MockedData.getGameAnalyticsJSON]
    ).register()

    let (analytics, _) = try await helix.getGameAnalytics()

    XCTAssertEqual(analytics.count, 1)

    XCTAssert(analytics.contains(where: { $0.gameId == "9821" }))

    XCTAssertEqual(analytics.first?.range.start.ISO8601Format(), "2018-03-13T00:00:00Z")
    XCTAssertEqual(analytics.first?.range.end.ISO8601Format(), "2018-06-13T00:00:00Z")
  }
}
