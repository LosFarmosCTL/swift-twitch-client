import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
final class ModerationTests: XCTestCase {
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

  func testCheckAutomodStatus() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/moderation/enforcements/status?broadcaster_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.post: MockedData.checkAutomodStatusJSON]
    ).register()

    let result = try await twitch.request(
      endpoint: .checkAutomodStatus(
        messages: ("123", "This is a test message."),
        ("393", "This is another test message."))
    )

    XCTAssertEqual(result.count, 2)
    XCTAssertEqual(result[0].messageID, "123")
    XCTAssertEqual(result[0].isPermitted, true)
    XCTAssertEqual(result[1].messageID, "393")
    XCTAssertEqual(result[1].isPermitted, false)
  }

  func testApproveAutomodMessage() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/moderation/automod/message")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.request(endpoint: .approveAutomodMessage(messageID: "123"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testDenyAutomodMessage() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/moderation/automod/message")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.request(endpoint: .denyAutomodMessage(messageID: "123"))

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

    let result = try await twitch.request(endpoint: .getAutomodSettings(of: "5678"))

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

    let result = try await twitch.request(
      endpoint: .updateAutomodSettings(of: "5678", overall: 3))

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

  func testGetBannedUsers() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/moderation/banned?broadcaster_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getBannedUsersJSON]
    ).register()

    let (bans, cursor) = try await twitch.request(endpoint: .getBannedUsers())

    XCTAssertEqual(cursor, "eyJiIjpudWxsLCJhIjp7IkN1cnNvciI")

    XCTAssertEqual(bans.count, 2)
    XCTAssertEqual(bans.first?.userID, "423374343")
  }

  func testBanUser() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/moderation/bans?broadcaster_id=5678&moderator_id=1234"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200, data: [.post: MockedData.banUserJSON]
    ).register()

    let ban = try await twitch.request(endpoint: .banUser("9876", in: "5678"))

    XCTAssertEqual(ban.broadcasterID, "5678")
    XCTAssertEqual(ban.moderatorID, "1234")
    XCTAssertEqual(ban.userID, "9876")
    XCTAssertNil(ban.endTime)
  }

  func testUnbanUser() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/moderation/bans?broadcaster_id=5678&moderator_id=1234&user_id=9876"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.request(endpoint: .unbanUser("9876", in: "5678"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testGetBlockedTerms() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/moderation/blocked_terms?broadcaster_id=5678&moderator_id=1234"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getBlockedTermsJSON]
    ).register()

    let (terms, cursor) = try await twitch.request(
      endpoint: .getBlockedTerms(in: "5678"))

    XCTAssertEqual(cursor, "eyJiIjpudWxsLCJhIjp7IkN1cnNvciI6I")

    XCTAssertEqual(terms.count, 1)
    XCTAssertEqual(terms.first?.text, "A phrase I'm not fond of")
    XCTAssertNil(terms.first?.expiresAt)
  }

  func testAddBlockedTerm() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/moderation/blocked_terms?broadcaster_id=5678&moderator_id=1234"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.post: MockedData.getBlockedTermsJSON]
    ).register()

    let term = try await twitch.request(
      endpoint: .addBlockedTerm(in: "5678", text: "A phrase I'm not fond of"))

    XCTAssertEqual(term.broadcasterID, "5678")
    XCTAssertEqual(term.moderatorID, "1234")
    XCTAssertEqual(term.text, "A phrase I'm not fond of")
    XCTAssertNil(term.expiresAt)
  }

  func testRemoveBlockedTerm() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/moderation/blocked_terms?broadcaster_id=5678&moderator_id=1234&id=9876"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.request(
      endpoint: .removeBlockedTerm(in: "5678", termID: "9876"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testDeleteChatMessage() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/moderation/chat?broadcaster_id=5678&moderator_id=1234&message_id=9876"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.request(endpoint: .deleteChatMessage(in: "5678", messageID: "9876"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testGetModeratedChannels() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/moderation/channels?user_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getModeratedChannelsJSON]
    ).register()

    let (channels, cursor) = try await twitch.request(endpoint: .getModeratedChannels())

    XCTAssertEqual(cursor, "eyJiIjpudWxsLCJhIjp7IkN1cnNvciI6")

    XCTAssertEqual(channels.count, 2)
    XCTAssertEqual(channels.first?.id, "12345")
    XCTAssertEqual(channels.last?.id, "98765")
  }

  func testGetModerators() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/moderation/moderators?broadcaster_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getModeratorsJSON]
    ).register()

    let (mods, cursor) = try await twitch.request(endpoint: .getModerators())

    XCTAssertEqual(cursor, "eyJiIjpudWxsLCJhIjp7IkN1cnNvciI6I")

    XCTAssertEqual(mods.count, 1)
    XCTAssertEqual(mods.first?.id, "424596340")
  }

  func testAddChannelModerator() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/moderation/moderators?broadcaster_id=1234&user_id=9876"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.request(endpoint: .addChannelModerator(userID: "9876"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testRemoveChannelModerator() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/moderation/moderators?broadcaster_id=1234&user_id=9876"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.request(endpoint: .removeChannelModerator(userID: "9876"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testGetVIPs() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/channels/vips?broadcaster_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200, data: [.get: MockedData.getVIPsJSON]
    ).register()

    let (vips, cursor) = try await twitch.request(endpoint: .getVIPs())

    XCTAssertEqual(cursor, "eyJiIjpudWxsLCJhIjp7Ik9mZnNldCI6NX19")

    XCTAssertEqual(vips.count, 1)
    XCTAssertEqual(vips.first?.id, "11111")
  }

  func testAddChannelVIP() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/channels/vips?broadcaster_id=1234&user_id=9876"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.request(endpoint: .addChannelVIP(userID: "9876"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testRemoveChannelVIP() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/channels/vips?broadcaster_id=1234&user_id=9876"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.request(endpoint: .removeChannelVIP(userID: "9876"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testGetShieldModeStatus() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/moderation/shield_mode?broadcaster_id=5678&moderator_id=1234"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getShieldModeStatusJSON]
    ).register()

    let result = try await twitch.request(endpoint: .getShieldModeStatus(of: "5678"))

    XCTAssertEqual(result.isActive, true)
    XCTAssertEqual(result.moderatorID, "1234")
  }

  func testUpdateShieldModeStatus() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/moderation/shield_mode?broadcaster_id=5678&moderator_id=1234"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.put: MockedData.getShieldModeStatusJSON]
    ).register()

    let result = try await twitch.request(
      endpoint: .updateShieldModeStatus(of: "5678", isActive: true))

    XCTAssertEqual(result.isActive, true)
    XCTAssertEqual(result.moderatorID, "1234")
  }
}
