import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class ChatTests: XCTestCase {
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

  func testGetChatters() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/chat/chatters?broadcaster_id=123&moderator_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getChattersJSON]
    ).register()

    let (total, analytics, cursor) = try await helix.getChatters(broadcasterId: "123")

    XCTAssertEqual(analytics.count, 1)
    XCTAssertEqual(total, 8)
    XCTAssertEqual(cursor, "eyJiIjpudWxsLCJhIjp7Ik9mZnNldCI6NX19")

    XCTAssert(analytics.contains(where: { $0.userId == "128393656" }))
  }

  func testGetChannelEmotes() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/chat/emotes?broadcaster_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getChannelEmotesJSON]
    ).register()

    let (templateUrl, emotes) = try await helix.getChannelEmotes(broadcasterId: "1234")

    XCTAssertEqual(
      templateUrl,
      "https://static-cdn.jtvnw.net/emoticons/v2/{{id}}/{{format}}/{{theme_mode}}/{{scale}}"
    )

    XCTAssertEqual(emotes.count, 2)
    XCTAssert(emotes.contains(where: { $0.id == "304456832" }))

    let emote = emotes.first(where: { $0.id == "304456832" })
    XCTAssertEqual(
      emote?.getURL(from: templateUrl)?.absoluteString,
      "https://static-cdn.jtvnw.net/emoticons/v2/304456832/static/dark/3.0")
  }

  func testGetGlobalEmotes() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/chat/emotes/global")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getGlobalEmotesJSON]
    ).register()

    let (templateUrl, emotes) = try await helix.getGlobalEmotes()

    XCTAssertEqual(
      templateUrl,
      "https://static-cdn.jtvnw.net/emoticons/v2/{{id}}/{{format}}/{{theme_mode}}/{{scale}}"
    )

    XCTAssertEqual(emotes.count, 1)
    XCTAssert(emotes.contains(where: { $0.id == "196892" }))

    let emote = emotes.first(where: { $0.id == "196892" })
    XCTAssertEqual(
      emote?.getURL(from: templateUrl)?.absoluteString,
      "https://static-cdn.jtvnw.net/emoticons/v2/196892/static/dark/3.0")
  }

  func testGetEmoteSets() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/chat/emotes/set?emote_set_id=123&emote_set_id=456")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getEmoteSetsJSON]
    ).register()

    let (templateUrl, emotes) = try await helix.getEmoteSets(setIds: ["123", "456"])

    XCTAssertEqual(
      templateUrl,
      "https://static-cdn.jtvnw.net/emoticons/v2/{{id}}/{{format}}/{{theme_mode}}/{{scale}}"
    )

    XCTAssertEqual(emotes.count, 1)
    XCTAssert(emotes.contains(where: { $0.id == "304456832" }))

    let emote = emotes.first(where: { $0.id == "304456832" })
    XCTAssertEqual(
      emote?.getURL(from: templateUrl)?.absoluteString,
      "https://static-cdn.jtvnw.net/emoticons/v2/304456832/static/dark/3.0")
  }

  func testGetChannelBadges() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/chat/badges?broadcaster_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getChannelBadgesJSON]
    ).register()

    let badgeSets = try await helix.getChannelBadges(broadcasterId: "1234")

    XCTAssertEqual(badgeSets.count, 2)

    XCTAssertEqual(
      badgeSets.first?.badges.first?.images.url1x.absoluteString,
      "https://static-cdn.jtvnw.net/badges/v1/743a0f3b-84b3-450b-96a0-503d7f4a9764/1")
  }

  func testGetGlobalBadges() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/chat/badges/global")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getGlobalBadgesJSON]
    ).register()

    let badgeSets = try await helix.getGlobalBadges()

    XCTAssertEqual(badgeSets.count, 1)

    XCTAssertEqual(
      badgeSets.first?.badges.first?.images.url1x.absoluteString,
      "https://static-cdn.jtvnw.net/badges/v1/b817aba4-fad8-49e2-b88a-7cc744dfa6ec/1")
  }

  func testGetChatSettings() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/chat/settings?broadcaster_id=713936733&moderator_id=1234"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getChatSettingsJSON]
    ).register()

    let settings = try await helix.getChatSettings(
      broadcasterId: "713936733", moderatorId: "1234")

    XCTAssertEqual(settings.broadcasterId, "713936733")
    XCTAssertEqual(settings.slowModeWaitTime, 5)
    XCTAssertEqual(settings.followerModeDuration, 0)
    XCTAssertEqual(settings.subscriberMode, true)
    XCTAssertEqual(settings.emoteMode, false)
    XCTAssertEqual(settings.uniqueChatMode, false)
    XCTAssertEqual(settings.nonModeratorChatDelay, 4)
  }

  func testUpdateChatSettings() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/chat/settings?broadcaster_id=713936733&moderator_id=1234"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.patch: MockedData.getChatSettingsJSON]
    ).register()

    let settings = try await helix.updateChatSettings(
      broadcasterId: "713936733", .slowMode(5), .subscriberMode, .followerMode())

    XCTAssertEqual(settings.broadcasterId, "713936733")
    XCTAssertEqual(settings.slowModeWaitTime, 5)
    XCTAssertEqual(settings.followerModeDuration, 0)
    XCTAssertEqual(settings.subscriberMode, true)
    XCTAssertEqual(settings.emoteMode, false)
    XCTAssertEqual(settings.uniqueChatMode, false)
    XCTAssertEqual(settings.nonModeratorChatDelay, 4)
  }

  func testSendAnnouncement() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/chat/announcements?broadcaster_id=1234&moderator_id=1234"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await helix.sendAnnouncement(
      broadcasterId: "1234", message: "Hello, world!", color: .blue)

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testSendShoutout() async throws {
    let url = URL(
      string:  // swiftlint:disable:next line_length
        "https://api.twitch.tv/helix/chat/announcements?from_broadcaster_id=1234&to_broadcaster_id=4321&moderator_id=1234"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await helix.sendShoutout(from: "1234", to: "4321")

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testGetUserColor() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/chat/color?user_id=11111&user_id=44444")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getUserColorJSON]
    ).register()

    let colors = try await helix.getUserColor(userIDs: ["11111", "44444"])

    XCTAssertEqual(colors.count, 2)

    XCTAssert(colors.contains(where: { $0.userId == "11111" }))
  }

  func testUpdateUserColor() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/chat/color?user_id=1234&color=blue")!

    var request = URLRequest(url: url)
    request.httpMethod = "PUT"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await helix.updateUserColor(color: .blue)

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }
}
