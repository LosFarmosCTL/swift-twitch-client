import Foundation
import Testing

@testable import Twitch

// swiftlint:disable:next type_body_length
struct ChatTests {
  private let harness = HelixTestHarness()

  @Test
  func getSharedChatSession() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/shared_chat/session?broadcaster_id=198704263"
      ))

    await harness.session.stub(url: url, body: MockedData.getSharedChatSessionJSON)

    let session = try #require(
      await harness.twitch.helix(for: .getSharedChatSession(for: "198704263")))

    #expect(session.sessionID == "359bce59-fa4e-41a5-bd6f-9bc0c8360485")
    #expect(session.hostBroadcasterID == "198704263")
    #expect(session.participants.map(\.broadcasterID) == ["198704263", "487263401"])
    #expect(session.createdAt.formatted(.iso8601) == "2024-09-29T19:45:37Z")
  }

  @Test
  func getUserEmotes() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/chat/emotes/user?user_id=1234&broadcaster_id=channel&after=next"
      ))

    await harness.session.stub(url: url, body: MockedData.getUserEmotesJSON)

    let result = try await harness.twitch.helix(
      for: .getUserEmotes(broadcasterID: "channel", after: "next"))

    #expect(result.cursor == "eyJiIjpudWxsLJxhIjoiIn0gf5")
    #expect(result.emotes.count == 1)
    let emote = try #require(result.emotes.first)
    #expect(emote.id == "304420818")
    #expect(emote.ownerID == "477339272")
    #expect(emote.type == "hypetrain")
    #expect(
      emote.getURL(from: result.template)?.absoluteString
        == "https://static-cdn.jtvnw.net/emoticons/v2/304420818/static/dark/3.0")
  }

  @Test
  func getPinnedChatMessage() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/chat/pins?broadcaster_id=197886470&moderator_id=1234"
      ))

    await harness.session.stub(url: url, body: MockedData.getPinnedChatMessageJSON)

    let message = try #require(
      await harness.twitch.helix(for: .getPinnedChatMessage(in: "197886470")))

    #expect(message.messageID == "abc-def-123-456")
    #expect(message.senderID == "12826")
    #expect(message.pinnedByID == "141981764")
    #expect(message.message.text == "Welcome! bleedPurple Type !rules")
    #expect(message.message.fragments.count == 3)
    #expect(message.startsAt.formatted(.iso8601) == "2026-05-06T12:30:00Z")
    #expect(message.endsAt?.formatted(.iso8601) == "2026-05-06T12:35:00Z")
  }

  @Test
  func pinChatMessage() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/chat/pins?broadcaster_id=channel&moderator_id=1234&message_id=message&duration_seconds=300"
      ))

    await harness.session.stub(url: url, method: "PUT", status: 204)

    try await harness.twitch.helix(
      for: .pinChatMessage("message", in: "channel", durationSeconds: 300))
  }

  @Test
  func updatePinnedChatMessage() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/chat/pins?broadcaster_id=channel&moderator_id=1234&message_id=message&duration_seconds=600"
      ))

    await harness.session.stub(url: url, method: "PATCH", status: 204)

    try await harness.twitch.helix(
      for: .updatePinnedChatMessage("message", in: "channel", durationSeconds: 600))
  }

  @Test
  func unpinChatMessage() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/chat/pins?broadcaster_id=channel&moderator_id=1234&message_id=message"
      ))

    await harness.session.stub(url: url, method: "DELETE", status: 204)

    try await harness.twitch.helix(for: .unpinChatMessage("message", in: "channel"))
  }

  @Test
  func sendChatMessage() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/chat/messages"))

    await harness.session.stub(
      url: url, method: "POST", body: MockedData.sendChatMessageJSON)

    let message = try await harness.twitch.helix(
      for: .sendChatMessage(in: "12826", message: "Hello, world! twitchdevHype"))

    #expect(message.messageID == "abc-123-def")
    #expect(message.isSent == true)
    #expect(message.dropReason == nil)
  }

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

    let result = try await harness.twitch.helix(for: .getChatters(in: "123"))

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
      for: .getChannelEmotes(of: "1234"))

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

    let result = try await harness.twitch.helix(for: .getGlobalEmotes())

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
      for: .getEmoteSets(["123", "456"]))

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
      for: .getChannelBadges(of: "1234")
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

    let badgeSets = try await harness.twitch.helix(for: .getGlobalBadges())

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
      for: .getChatSettings(of: "713936733", moderatorID: "1234"))

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
      for: .updateChatSettings(
        of: "713936733", settings: .slowMode(5), .subscriberMode, .followerMode()))

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
      for: .sendAnnouncement(in: "1234", message: "Hello, world!", color: .blue))
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

    try await harness.twitch.helix(
      for: .sendShoutout(from: "1234", to: "4321"))
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
      for: .getUserColors(of: ["11111", "44444"])
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

    try await harness.twitch.helix(for: .updateUserColor(to: .blue))
  }
}
