import Foundation
import Testing

@testable import Twitch

struct ModerationTests {
  let harness = HelixTestHarness()

  @Test
  func warnChatUser() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/warnings?broadcaster_id=404040&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url, method: "POST", body: MockedData.warnChatUserJSON)

    let warning =
      (try await harness.twitch.helix(
        for: .warnChatUser("9876", in: "404040", reason: "stop doing that!"))).value

    #expect(warning.broadcasterID == "404040")
    #expect(warning.userID == "9876")
    #expect(warning.moderatorID == "404041")
    #expect(warning.reason == "stop doing that!")
  }

  @Test
  func addSuspiciousStatusToChatUser() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/suspicious_users?broadcaster_id=141981764&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url, method: "POST", body: MockedData.addSuspiciousStatusToChatUserJSON)

    let status =
      (try await harness.twitch.helix(
        for: .addSuspiciousStatusToChatUser("9876", in: "141981764", status: .restricted)))
      .value

    #expect(status.userID == "9876")
    #expect(status.broadcasterID == "141981764")
    #expect(status.status == "RESTRICTED")
    #expect(status.types == ["MANUALLY_ADDED"])
    #expect(status.updatedAt.formatted(.iso8601) == "2025-12-01T23:08:18Z")
  }

  @Test
  func removeSuspiciousStatusFromChatUser() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/suspicious_users?broadcaster_id=141981764&moderator_id=1234&user_id=9876"
      ))

    await harness.session.stub(
      url: url, method: "DELETE", body: MockedData.removeSuspiciousStatusFromChatUserJSON)

    let status =
      (try await harness.twitch.helix(
        for: .removeSuspiciousStatusFromChatUser("9876", in: "141981764"))).value

    #expect(status.userID == "9876")
    #expect(status.broadcasterID == "141981764")
    #expect(status.status == "NO_TREATMENT")
    #expect(status.types == ["MANUALLY_ADDED"])
  }

  @Test
  func deleteChatMessage() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/chat?broadcaster_id=5678&moderator_id=1234&message_id=9876"
      ))

    await harness.session.stub(
      url: url,
      method: "DELETE",
      status: 204)

    try await harness.twitch.helix(
      for: .deleteChatMessage(in: "5678", messageID: "9876"))
  }
}
