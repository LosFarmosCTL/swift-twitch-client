import Foundation
import Testing

@testable import Twitch

extension ChatTests {
  @Test
  func getUserEmotes() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/chat/emotes/user?user_id=1234&broadcaster_id=channel&after=next"
      ))

    await harness.session.stub(url: url, body: MockedData.getUserEmotesJSON)

    let result =
      (try await harness.twitch.helix(
        for: .getUserEmotes(broadcasterID: "channel", after: "next"))).value

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
  func getChannelEmotes() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/chat/emotes?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getChannelEmotesJSON)

    let result =
      (try await harness.twitch.helix(
        for: .getChannelEmotes(of: "1234"))).value

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

    let result = (try await harness.twitch.helix(for: .getGlobalEmotes())).value

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

    let result =
      (try await harness.twitch.helix(
        for: .getEmoteSets(["123", "456"]))).value

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
}
