import Foundation
import Testing

@testable import Twitch

struct ChatTests {
  private let harness = HelixTestHarness()

  @Test
  func getChatters() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/chat/chatters?broadcaster_id=123&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getChattersJSON)

    let result = try await harness.twitch.helix(endpoint: .getChatters(in: "123"))

    #expect(result.chatters.count == 1)
    #expect(result.total == 8)
    #expect(result.cursor == "eyJiIjpudWxsLCJhIjp7Ik9mZnNldCI6NX19")

    #expect(result.chatters.contains(where: { $0.userID == "128393656" }))
  }

  @Test
  func getChannelEmotes() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/chat/emotes?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getChannelEmotesJSON)

    let result = try await harness.twitch.helix(
      endpoint: .getChannelEmotes(of: "1234"))

    #expect(
      result.template
        == "https://static-cdn.jtvnw.net/emoticons/v2/{{id}}/{{format}}/{{theme_mode}}/{{scale}}"
    )

    #expect(result.emotes.count == 2)
    #expect(result.emotes.contains(where: { $0.id == "304456832" }))

    let emote = result.emotes.first(where: { $0.id == "304456832" })
    #expect(
      emote?.getURL(from: result.template)?.absoluteString
        == "https://static-cdn.jtvnw.net/emoticons/v2/304456832/static/dark/3.0")
  }

  @Test
  func getGlobalEmotes() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/chat/emotes/global"))

    await harness.session.stub(
      url: url,
      body: MockedData.getGlobalEmotesJSON)

    let result = try await harness.twitch.helix(endpoint: .getGlobalEmotes())

    #expect(
      result.template
        == "https://static-cdn.jtvnw.net/emoticons/v2/{{id}}/{{format}}/{{theme_mode}}/{{scale}}"
    )

    #expect(result.emotes.count == 1)
    #expect(result.emotes.contains(where: { $0.id == "196892" }))

    let emote = result.emotes.first(where: { $0.id == "196892" })
    #expect(
      emote?.getURL(from: result.template)?.absoluteString
        == "https://static-cdn.jtvnw.net/emoticons/v2/196892/static/dark/3.0")
  }

  @Test
  func getEmoteSets() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/chat/emotes/set?emote_set_id=123&emote_set_id=456")
    )

    await harness.session.stub(
      url: url,
      body: MockedData.getEmoteSetsJSON)

    let result = try await harness.twitch.helix(
      endpoint: .getEmoteSets(["123", "456"]))

    #expect(
      result.template
        == "https://static-cdn.jtvnw.net/emoticons/v2/{{id}}/{{format}}/{{theme_mode}}/{{scale}}"
    )

    #expect(result.emotes.count == 1)
    #expect(result.emotes.contains(where: { $0.id == "304456832" }))

    let emote = result.emotes.first(where: { $0.id == "304456832" })
    #expect(
      emote?.getURL(from: result.template)?.absoluteString
        == "https://static-cdn.jtvnw.net/emoticons/v2/304456832/static/dark/3.0")
  }

  @Test
  func getChannelBadges() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/chat/badges?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getChannelBadgesJSON)

    let badgeSets = try await harness.twitch.helix(
      endpoint: .getChannelBadges(of: "1234")
    )

    #expect(badgeSets.count == 2)

    #expect(
      badgeSets.first?.badges.first?.images.url1x.absoluteString
        == "https://static-cdn.jtvnw.net/badges/v1/743a0f3b-84b3-450b-96a0-503d7f4a9764/1"
    )
  }

  @Test
  func getGlobalBadges() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/chat/badges/global"))

    await harness.session.stub(
      url: url,
      body: MockedData.getGlobalBadgesJSON)

    let badgeSets = try await harness.twitch.helix(endpoint: .getGlobalBadges())

    #expect(badgeSets.count == 1)

    #expect(
      badgeSets.first?.badges.first?.images.url1x.absoluteString
        == "https://static-cdn.jtvnw.net/badges/v1/b817aba4-fad8-49e2-b88a-7cc744dfa6ec/1"
    )
  }

  @Test
  func getChatSettings() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/chat/settings?broadcaster_id=713936733&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getChatSettingsJSON)

    let settings = try await harness.twitch.helix(
      endpoint: .getChatSettings(of: "713936733", moderatorID: "1234"))

    #expect(settings.broadcasterID == "713936733")
    #expect(settings.slowModeWaitTime == 5)
    #expect(settings.followerModeDuration == 0)
    #expect(settings.subscriberMode == true)
    #expect(settings.emoteMode == false)
    #expect(settings.uniqueChatMode == false)
    #expect(settings.nonModeratorChatDelay == 4)
  }

  @Test
  func updateChatSettings() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/chat/settings?broadcaster_id=713936733&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url,
      method: "PATCH",
      body: MockedData.getChatSettingsJSON)

    let settings = try await harness.twitch.helix(
      endpoint: .updateChatSettings(
        of: "713936733", .slowMode(5), .subscriberMode, .followerMode()))

    #expect(settings.broadcasterID == "713936733")
    #expect(settings.slowModeWaitTime == 5)
    #expect(settings.followerModeDuration == 0)
    #expect(settings.subscriberMode == true)
    #expect(settings.emoteMode == false)
    #expect(settings.uniqueChatMode == false)
    #expect(settings.nonModeratorChatDelay == 4)
  }

  @Test
  func sendAnnouncement() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/chat/announcements?broadcaster_id=1234&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url,
      method: "POST",
      status: 204)

    try await harness.twitch.helix(
      endpoint: .sendAnnouncement(in: "1234", message: "Hello, world!", color: .blue))
  }

  @Test
  func sendShoutout() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/chat/shoutouts?from_broadcaster_id=1234&to_broadcaster_id=4321&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url,
      method: "POST",
      status: 204)

    try await harness.twitch.helix(endpoint: .sendShoutout(from: "1234", to: "4321"))
  }

  @Test
  func getUserColor() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/chat/color?user_id=11111&user_id=44444"))

    await harness.session.stub(
      url: url,
      body: MockedData.getUserColorJSON)

    let colors = try await harness.twitch.helix(
      endpoint: .getUserColors(of: ["11111", "44444"])
    )

    #expect(colors.count == 2)

    #expect(colors.contains(where: { $0.userID == "11111" }))
  }

  @Test
  func updateUserColor() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/chat/color?user_id=1234&color=blue"))

    await harness.session.stub(
      url: url,
      method: "PUT",
      status: 204)

    try await harness.twitch.helix(endpoint: .updateUserColor(to: .blue))
  }
}
