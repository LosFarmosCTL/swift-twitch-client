import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class ModerationTests: XCTestCase {
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

  func testCheckAutomodStatus() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/moderation/enforcements/status?broadcaster_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.checkAutomodStatusJSON]
    ).register()

    let result = try await helix.checkAutomodStatus(
      messages: ("123", "This is a test message."),
      ("393", "This is another test message."))

    XCTAssertEqual(result.count, 2)
    XCTAssertEqual(result[0].msgId, "123")
    XCTAssertEqual(result[0].isPermitted, true)
    XCTAssertEqual(result[1].msgId, "393")
    XCTAssertEqual(result[1].isPermitted, false)
  }

  func testApproveAutomodMessage() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/moderation/automod/message")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await helix.approveAutomodMessage(withID: "123")

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testDenyAutomodMessage() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/moderation/automod/message")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await helix.denyAutomodMessage(withID: "123")

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testGetAutomodSettings() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/moderation/automod/settings?broadcaster_id=5678&moderator_id=1234"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getAutomodSettingsJSON]
    ).register()

    let result = try await helix.getAutomodSettings(broadcasterId: "5678")

    XCTAssertEqual(result.broadcasterID, "5678")
    XCTAssertEqual(result.moderatorID, "1234")

    XCTAssertNil(result.overallLevel)
    XCTAssertEqual(result.disability, 0)
  }

  func testUpdateAutomodSettings() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/moderation/automod/settings?broadcaster_id=5678&moderator_id=1234"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.put: MockedData.updateAutomodSettingsJSON]
    ).register()

    let result = try await helix.updateAutomodSettings(forChannel: "5678", overall: 3)

    XCTAssertEqual(result.broadcasterID, "5678")
    XCTAssertEqual(result.moderatorID, "1234")
    XCTAssertEqual(result.overallLevel, 3)

    XCTAssertEqual(result.disability, 3)
    XCTAssertEqual(result.aggression, 3)
    XCTAssertEqual(result.sexualitySexOrGender, 3)
    XCTAssertEqual(result.misogyny, 3)
    XCTAssertEqual(result.bullying, 2)
    XCTAssertEqual(result.swearing, 0)
    XCTAssertEqual(result.raceEthnicityOrReligion, 3)
    XCTAssertEqual(result.sexBasedTerms, 3)
  }
}
