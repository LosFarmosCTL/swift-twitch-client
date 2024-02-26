import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class ChatTests: XCTestCase {
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

  func testGetChatters() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/chat/chatters?broadcaster_id=123&moderator_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getChattersJSON]
    ).register()

    let result = try await twitch.request(
      endpoint: .getChatters(in: "123", moderatorID: "1234"))

    XCTAssertEqual(result.data.count, 1)
    XCTAssertEqual(result.total, 8)
    XCTAssertEqual(
      result.pagination?.cursor, "eyJiIjpudWxsLCJhIjp7Ik9mZnNldCI6NX19")

    XCTAssert(result.data.contains(where: { $0.userID == "128393656" }))
  }

  func testGetChannelEmotes() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/chat/emotes?broadcaster_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getChannelEmotesJSON]
    ).register()

    let result = try await twitch.request(
      endpoint: .getChannelEmotes(of: "1234"))

    XCTAssertEqual(
      result.template,
      "https://static-cdn.jtvnw.net/emoticons/v2/{{id}}/{{format}}/{{theme_mode}}/{{scale}}"
    )

    XCTAssertEqual(result.data.count, 2)
    XCTAssert(result.data.contains(where: { $0.id == "304456832" }))

    let emote = result.data.first(where: { $0.id == "304456832" })
    XCTAssertEqual(
      emote?.getURL(from: result.template!)?.absoluteString,
      "https://static-cdn.jtvnw.net/emoticons/v2/304456832/static/dark/3.0")
  }

  func testGetGlobalEmotes() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/chat/emotes/global")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getGlobalEmotesJSON]
    ).register()

    let result = try await twitch.request(endpoint: .getGlobalEmotes())

    XCTAssertEqual(
      result.template,
      "https://static-cdn.jtvnw.net/emoticons/v2/{{id}}/{{format}}/{{theme_mode}}/{{scale}}"
    )

    XCTAssertEqual(result.data.count, 1)
    XCTAssert(result.data.contains(where: { $0.id == "196892" }))

    let emote = result.data.first(where: { $0.id == "196892" })
    XCTAssertEqual(
      emote?.getURL(from: result.template!)?.absoluteString,
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

    let result = try await twitch.request(
      endpoint: .getEmoteSets(["123", "456"]))

    XCTAssertEqual(
      result.template,
      "https://static-cdn.jtvnw.net/emoticons/v2/{{id}}/{{format}}/{{theme_mode}}/{{scale}}"
    )

    XCTAssertEqual(result.data.count, 1)
    XCTAssert(result.data.contains(where: { $0.id == "304456832" }))

    let emote = result.data.first(where: { $0.id == "304456832" })
    XCTAssertEqual(
      emote?.getURL(from: result.template!)?.absoluteString,
      "https://static-cdn.jtvnw.net/emoticons/v2/304456832/static/dark/3.0")
  }

  func testGetChannelBadges() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/chat/badges?broadcaster_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getChannelBadgesJSON]
    ).register()

    let badgeSets = try await twitch.request(
      endpoint: .getChannelBadges(of: "1234")
    ).data

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

    let badgeSets = try await twitch.request(endpoint: .getGlobalBadges()).data

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

    let settings = try await twitch.request(
      endpoint: .getChatSettings(of: "713936733", moderatorID: "1234"))

    XCTAssertEqual(settings.broadcasterID, "713936733")
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

    let settings = try await twitch.request(
      endpoint: .updateChatSettings(
        of: "713936733", moderatorID: "1234", .slowMode(5), .subscriberMode,
        .followerMode()))

    XCTAssertEqual(settings.broadcasterID, "713936733")
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

    try await twitch.request(
      endpoint: .sendAnnouncement(
        in: "1234", message: "Hello, world!", color: .blue, moderatorID: "1234"
      ))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testSendShoutout() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/chat/shoutouts?from_broadcaster_id=1234&to_broadcaster_id=4321&moderator_id=1234"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.request(
      endpoint: .sendShoutout(from: "1234", to: "4321", moderatorID: "1234"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testGetUserColor() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/chat/color?user_id=11111&user_id=44444")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getUserColorJSON]
    ).register()

    let colors = try await twitch.request(
      endpoint: .getUserColors(of: ["11111", "44444"])
    ).data

    XCTAssertEqual(colors.count, 2)

    XCTAssert(colors.contains(where: { $0.userID == "11111" }))
  }

  func testUpdateUserColor() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/chat/color?user_id=1234&color=blue")!

    var request = URLRequest(url: url)
    request.httpMethod = "PUT"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.request(
      endpoint: .updateUserColor(of: "1234", color: .blue))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }
}
