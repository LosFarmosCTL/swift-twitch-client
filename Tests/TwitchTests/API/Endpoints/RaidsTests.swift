import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class RaidsTests: XCTestCase {
  private var twitch: TwitchClient!

  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    let urlSession = URLSession(configuration: configuration)

    twitch = TwitchClient(
      authentication: .init(
        oAuth: "1234567989", clientID: "abcdefghijkl", userID: "1234",
        userLogin: "user"),
      urlSession: urlSession)
  }

  func testStartRaid() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/raids?from_broadcaster_id=1234&to_broadcaster_id=5678"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.post: MockedData.startRaidJSON]
    ).register()

    let raid = try await twitch.helix(endpoint: .startRaid(to: "5678"))

    XCTAssertEqual(raid.createdAt.formatted(.iso8601), "2022-02-18T07:20:50Z")
    XCTAssertEqual(raid.isMature, false)
  }

  func testCancelRaid() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/raids?broadcaster_id=1234")!

    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.helix(endpoint: .cancelRaid())

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }
}
