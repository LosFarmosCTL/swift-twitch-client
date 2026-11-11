import Foundation
import Testing

@testable import Twitch

struct ChatTests {
  let harness = HelixTestHarness()

  @Test
  func getSharedChatSession() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/shared_chat/session?broadcaster_id=198704263"
      ))

    await harness.session.stub(url: url, body: MockedData.getSharedChatSessionJSON)

    let session = try #require(
      await harness.twitch.helix(for: .getSharedChatSession(for: "198704263")).value)

    #expect(session.sessionID == "359bce59-fa4e-41a5-bd6f-9bc0c8360485")
    #expect(session.hostBroadcasterID == "198704263")
    #expect(session.participants.map(\.broadcasterID) == ["198704263", "487263401"])
    #expect(session.createdAt.formatted(.iso8601) == "2024-09-29T19:45:37Z")
  }

  @Test
  func sendChatMessage() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/chat/messages"))

    await harness.session.stub(
      url: url, method: "POST", body: MockedData.sendChatMessageJSON)

    let message =
      (try await harness.twitch.helix(
        for: .sendChatMessage(in: "12826", message: "Hello, world! twitchdevHype"))).value

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

    let result = (try await harness.twitch.helix(for: .getChatters(in: "123"))).value

    #expect(result.chatters.count == 1)
    #expect(result.total == 8)
    #expect(result.cursor == "eyJiIjpudWxsLCJhIjp7Ik9mZnNldCI6NX19")

    #expect(result.chatters.contains(where: { $0.userID == "128393656" }))
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

  @Test(arguments: [false, true])
  func getUserColor(noUsersFound: Bool) async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/chat/color?user_id=11111&user_id=44444"))

    await harness.session.stub(
      url: url,
      body: noUsersFound ? Data(#"{"data":null}"#.utf8) : MockedData.getUserColorJSON)

    let colors =
      (try await harness.twitch.helix(
        for: .getUserColors(of: ["11111", "44444"])
      )).value

    #expect(colors.count == (noUsersFound ? 0 : 2))
    #expect(colors.contains(where: { $0.userID == "11111" }) == !noUsersFound)
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
