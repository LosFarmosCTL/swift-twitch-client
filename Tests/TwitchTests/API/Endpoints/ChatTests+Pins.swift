import Foundation
import Testing

@testable import Twitch

extension ChatTests {
  @Test(arguments: [false, true])
  func getPinnedChatMessage(contentUnavailable: Bool) async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/chat/pins?broadcaster_id=197886470&moderator_id=1234"
      ))

    var payload = try #require(
      JSONSerialization.jsonObject(with: MockedData.getPinnedChatMessageJSON)
        as? [String: Any])
    if contentUnavailable {
      var rows = try #require(payload["data"] as? [[String: Any]])
      rows[0]["message"] = NSNull()
      payload["data"] = rows
    }
    await harness.session.stub(
      url: url, body: try JSONSerialization.data(withJSONObject: payload))

    let message = try #require(
      await harness.twitch.helix(for: .getPinnedChatMessage(in: "197886470")).value)

    #expect(message.messageID == "abc-def-123-456")
    #expect(message.senderID == "12826")
    #expect(message.pinnedByID == "141981764")
    if contentUnavailable {
      #expect(message.message == nil)
    } else {
      #expect(message.message?.text == "Welcome! bleedPurple Type !rules")
      #expect(message.message?.fragments.count == 3)
    }
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

    (try await harness.twitch.helix(
      for: .updatePinnedChatMessage("message", in: "channel", durationSeconds: 600)))
      .value
  }

  @Test
  func unpinChatMessage() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/chat/pins?broadcaster_id=channel&moderator_id=1234&message_id=message"
      ))

    await harness.session.stub(url: url, method: "DELETE", status: 204)

    (try await harness.twitch.helix(for: .unpinChatMessage("message", in: "channel")))
      .value
  }
}
