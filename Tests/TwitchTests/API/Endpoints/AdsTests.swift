import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class AdsTests: XCTestCase {
  private var helix: Helix!

  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    let urlSession = URLSession(configuration: configuration)

    helix = try Helix(
      authentication: .init(oAuth: "1234567989", clientID: "abcdefghijkl"),
      urlSession: urlSession)
  }

  func testGetAdSchedule() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/channels/ads?broadcaster_id=1234")!

    Mock(
      url: url, dataType: .json, statusCode: 200,
      data: [.get: MockedData.getAdScheduleJSON]
    ).register()

    let ads = try await helix.getAdSchedule(broadcasterId: "1234")

    XCTAssertEqual(ads.count, 1)

    XCTAssertEqual(ads.first?.duration, 60)
    XCTAssertEqual(ads.first?.nextAdAt.ISO8601Format(), "2023-08-01T23:08:18Z")
  }

  func testStartCommercial() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/channels/commercial")!

    Mock(
      url: url, dataType: .json, statusCode: 200,
      data: [.post: MockedData.startCommercialJSON]
    ).register()

    let commercial = try await helix.startCommercial(broadcasterId: "1234", length: 60)

    XCTAssertEqual(commercial.length, 60)
    XCTAssertEqual(commercial.message, "")
    XCTAssertEqual(commercial.retryAfter, 480)
  }

  func testSnoozeNextAd() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/channels/ads/schedule/snooze?broadcaster_id=1234")!

    Mock(
      url: url, dataType: .json, statusCode: 200,
      data: [.post: MockedData.snoozeNextAdJSON]
    ).register()

    let snoozeResult = try await helix.snoozeNextAd(broadcasterId: "1234")

    XCTAssertEqual(snoozeResult.count, 1)
    XCTAssertEqual(snoozeResult.first?.snoozeCount, 1)
    XCTAssertEqual(
      snoozeResult.first?.snoozeRefreshAt.ISO8601Format(), "2023-08-01T23:08:18Z")
  }
}
