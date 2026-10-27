import Foundation
import Testing

@testable import Twitch

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
struct ModerationTests {
  private let harness = HelixTestHarness()

  @Test
  func getUnbanRequests() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/unban_requests?broadcaster_id=274637212&moderator_id=1234&status=pending&first=20"
      ))

    await harness.session.stub(url: url, body: MockedData.getUnbanRequestsJSON)

    let (requests, cursor) = try await harness.twitch.helix(
      for: .getUnbanRequests(in: "274637212", status: .pending, limit: 20))

    #expect(cursor != nil)
    #expect(requests.count == 1)
    let request = try #require(requests.first)
    #expect(request.id == "92af127c-7326-4483-a52b-b0da0be61c01")
    #expect(request.userID == "424596340")
    #expect(request.status == "pending")
    #expect(request.resolvedAt == nil)
    #expect(request.resolutionText == nil)
  }

  @Test
  func resolveUnbanRequest() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/unban_requests?broadcaster_id=274637212&moderator_id=1234&unban_request_id=request&status=approved&resolution_text=Welcome%20back!"
      ))

    await harness.session.stub(
      url: url, method: "PATCH", body: MockedData.resolveUnbanRequestJSON)

    let request = try await harness.twitch.helix(
      for: .resolveUnbanRequest(
        "request", in: "274637212", status: .approved, resolutionText: "Welcome back!"))

    #expect(request.id == "92af127c-7326-4483-a52b-b0da0be61c01")
    #expect(request.userID == "424596340")
    #expect(request.status == "approved")
    #expect(request.resolvedAt?.formatted(.iso8601) == "2022-08-09T02:07:55Z")
  }

  @Test
  func warnChatUser() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/warnings?broadcaster_id=404040&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url, method: "POST", body: MockedData.warnChatUserJSON)

    let warning = try await harness.twitch.helix(
      for: .warnChatUser("9876", in: "404040", reason: "stop doing that!"))

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

    let status = try await harness.twitch.helix(
      for: .addSuspiciousStatusToChatUser("9876", in: "141981764", status: .restricted))

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

    let status = try await harness.twitch.helix(
      for: .removeSuspiciousStatusFromChatUser("9876", in: "141981764"))

    #expect(status.userID == "9876")
    #expect(status.broadcasterID == "141981764")
    #expect(status.status == "NO_TREATMENT")
    #expect(status.types == ["MANUALLY_ADDED"])
  }

  @Test
  func checkAutoModStatus() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/enforcements/status?broadcaster_id=1234"
      ))

    await harness.session.stub(
      url: url,
      method: "POST",
      body: MockedData.checkAutoModStatusJSON)

    let result = try await harness.twitch.helix(
      for: .checkAutoModStatus(
        messages: ("123", "This is a test message."),
        ("393", "This is another test message."))
    )

    #expect(result.count == 2)
    #expect(result[0].messageID == "123")
    #expect(result[0].isPermitted == true)
    #expect(result[1].messageID == "393")
    #expect(result[1].isPermitted == false)
  }

  @Test
  func approveAutoModMessage() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/moderation/automod/message"))

    await harness.session.stub(
      url: url,
      method: "POST",
      status: 204)

    try await harness.twitch.helix(for: .approveAutoModMessage(messageID: "123"))

    let request = try #require(await harness.session.lastRequest())
    let body = try #require(request.httpBody)
    let fields = try JSONDecoder().decode([String: String].self, from: body)
    #expect(fields == ["user_id": "1234", "msg_id": "123", "action": "ALLOW"])
  }

  @Test
  func denyAutoModMessage() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/moderation/automod/message"))

    await harness.session.stub(
      url: url,
      method: "POST",
      status: 204)

    try await harness.twitch.helix(for: .denyAutoModMessage(messageID: "123"))

    let request = try #require(await harness.session.lastRequest())
    let body = try #require(request.httpBody)
    let fields = try JSONDecoder().decode([String: String].self, from: body)
    #expect(fields == ["user_id": "1234", "msg_id": "123", "action": "DENY"])
  }

  @Test
  func getAutoModSettings() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/automod/settings?broadcaster_id=5678&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getAutoModSettingsJSON)

    let result = try await harness.twitch.helix(for: .getAutoModSettings(of: "5678"))

    #expect(result.broadcasterID == "5678")
    #expect(result.moderatorID == "1234")

    #expect(result.overallLevel == nil)
    #expect(result.disability == 0)
  }

  @Test
  func updateAutoModSettings() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/automod/settings?broadcaster_id=5678&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url,
      method: "PUT",
      body: MockedData.updateAutoModSettingsJSON)

    let result = try await harness.twitch.helix(
      for: .updateAutoModSettings(of: "5678", overall: 3))

    #expect(result.broadcasterID == "5678")
    #expect(result.moderatorID == "1234")
    #expect(result.overallLevel == 3)

    #expect(result.disability == 3)
    #expect(result.aggression == 3)
    #expect(result.sexualitySexOrGender == 3)
    #expect(result.misogyny == 3)
    #expect(result.bullying == 2)
    #expect(result.swearing == 0)
    #expect(result.raceEthnicityOrReligion == 3)
    #expect(result.sexBasedTerms == 3)
  }

  @Test
  func getBannedUsers() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/moderation/banned?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getBannedUsersJSON)

    let (bans, cursor) = try await harness.twitch.helix(for: .getBannedUsers())

    #expect(cursor == "eyJiIjpudWxsLCJhIjp7IkN1cnNvciI")

    #expect(bans.count == 2)
    #expect(bans.first?.userID == "423374343")
  }

  @Test
  func banUser() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/bans?broadcaster_id=5678&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url,
      method: "POST",
      body: MockedData.banUserJSON)

    let ban = try await harness.twitch.helix(for: .banUser("9876", in: "5678"))

    #expect(ban.broadcasterID == "5678")
    #expect(ban.moderatorID == "1234")
    #expect(ban.userID == "9876")
    #expect(ban.endTime == nil)
  }

  @Test
  func unbanUser() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/bans?broadcaster_id=5678&moderator_id=1234&user_id=9876"
      ))

    await harness.session.stub(
      url: url,
      method: "DELETE",
      status: 204)

    try await harness.twitch.helix(for: .unbanUser("9876", in: "5678"))
  }

  @Test
  func getBlockedTerms() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/blocked_terms?broadcaster_id=5678&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getBlockedTermsJSON)

    let (terms, cursor) = try await harness.twitch.helix(
      for: .getBlockedTerms(in: "5678"))

    #expect(cursor == "eyJiIjpudWxsLCJhIjp7IkN1cnNvciI6I")

    #expect(terms.count == 1)
    #expect(terms.first?.text == "A phrase I'm not fond of")
    #expect(terms.first?.expiresAt == nil)
  }

  @Test
  func addBlockedTerm() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/blocked_terms?broadcaster_id=5678&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url,
      method: "POST",
      body: MockedData.getBlockedTermsJSON)

    let term = try await harness.twitch.helix(
      for: .addBlockedTerm(in: "5678", text: "A phrase I'm not fond of"))

    #expect(term.broadcasterID == "5678")
    #expect(term.moderatorID == "1234")
    #expect(term.text == "A phrase I'm not fond of")
    #expect(term.expiresAt == nil)
  }

  @Test
  func removeBlockedTerm() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/blocked_terms?broadcaster_id=5678&moderator_id=1234&id=9876"
      ))

    await harness.session.stub(
      url: url,
      method: "DELETE",
      status: 204)

    try await harness.twitch.helix(
      for: .removeBlockedTerm(in: "5678", termID: "9876"))
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

  @Test
  func getModeratedChannels() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/moderation/channels?user_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getModeratedChannelsJSON)

    let (channels, cursor) = try await harness.twitch.helix(
      for: .getModeratedChannels())

    #expect(cursor == "eyJiIjpudWxsLCJhIjp7IkN1cnNvciI6")

    #expect(channels.count == 2)
    #expect(channels.first?.id == "12345")
    #expect(channels.last?.id == "98765")
  }

  @Test
  func getModerators() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/moderation/moderators?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getModeratorsJSON)

    let (mods, cursor) = try await harness.twitch.helix(for: .getModerators())

    #expect(cursor == "eyJiIjpudWxsLCJhIjp7IkN1cnNvciI6I")

    #expect(mods.count == 1)
    #expect(mods.first?.id == "424596340")
  }

  @Test
  func addChannelModerator() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/moderators?broadcaster_id=1234&user_id=9876"
      ))

    await harness.session.stub(
      url: url,
      method: "POST",
      status: 204)

    try await harness.twitch.helix(for: .addChannelModerator(userID: "9876"))
  }

  @Test
  func removeChannelModerator() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/moderators?broadcaster_id=1234&user_id=9876"
      ))

    await harness.session.stub(
      url: url,
      method: "DELETE",
      status: 204)

    try await harness.twitch.helix(for: .removeChannelModerator(userID: "9876"))
  }

  @Test
  func getVIPs() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/channels/vips?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getVIPsJSON)

    let (vips, cursor) = try await harness.twitch.helix(for: .getVIPs())

    #expect(cursor == "eyJiIjpudWxsLCJhIjp7Ik9mZnNldCI6NX19")

    #expect(vips.count == 1)
    #expect(vips.first?.id == "11111")
  }

  @Test
  func addChannelVIP() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/channels/vips?broadcaster_id=1234&user_id=9876"
      ))

    await harness.session.stub(
      url: url,
      method: "POST",
      status: 204)

    try await harness.twitch.helix(for: .addChannelVIP(userID: "9876"))
  }

  @Test
  func removeChannelVIP() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/channels/vips?broadcaster_id=1234&user_id=9876"
      ))

    await harness.session.stub(
      url: url,
      method: "DELETE",
      status: 204)

    try await harness.twitch.helix(for: .removeChannelVIP(userID: "9876"))
  }

  @Test
  func getShieldModeStatus() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/shield_mode?broadcaster_id=5678&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getShieldModeStatusJSON)

    let result = try await harness.twitch.helix(
      for: .getShieldModeStatus(of: "5678"))

    #expect(result.isActive == true)
    #expect(result.moderatorID == "1234")
  }

  @Test
  func updateShieldModeStatus() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/shield_mode?broadcaster_id=5678&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url,
      method: "PUT",
      body: MockedData.getShieldModeStatusJSON)

    let result = try await harness.twitch.helix(
      for: .updateShieldModeStatus(of: "5678", isActive: true))

    #expect(result.isActive == true)
    #expect(result.moderatorID == "1234")
  }
}
