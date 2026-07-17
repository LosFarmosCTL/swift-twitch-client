import Foundation
import Testing

@testable import Twitch

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
struct ModerationTests {
  private let harness = HelixTestHarness()

  @Test
  func checkAutomodStatus() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/enforcements/status?broadcaster_id=1234"
      ))

    await harness.session.stub(
      url: url,
      method: "POST",
      body: MockedData.checkAutomodStatusJSON)

    let result = try await harness.twitch.helix(
      endpoint: .checkAutomodStatus(
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
  func approveAutomodMessage() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/moderation/automod/message"))

    await harness.session.stub(
      url: url,
      method: "POST",
      status: 204)

    try await harness.twitch.helix(endpoint: .approveAutomodMessage(messageID: "123"))
  }

  @Test
  func denyAutomodMessage() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/moderation/automod/message"))

    await harness.session.stub(
      url: url,
      method: "POST",
      status: 204)

    try await harness.twitch.helix(endpoint: .denyAutomodMessage(messageID: "123"))
  }

  @Test
  func getAutomodSettings() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/automod/settings?broadcaster_id=5678&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getAutomodSettingsJSON)

    let result = try await harness.twitch.helix(endpoint: .getAutomodSettings(of: "5678"))

    #expect(result.broadcasterID == "5678")
    #expect(result.moderatorID == "1234")

    #expect(result.overallLevel == nil)
    #expect(result.disability == 0)
  }

  @Test
  func updateAutomodSettings() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/automod/settings?broadcaster_id=5678&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url,
      method: "PUT",
      body: MockedData.updateAutomodSettingsJSON)

    let result = try await harness.twitch.helix(
      endpoint: .updateAutomodSettings(of: "5678", overall: 3))

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

    let (bans, cursor) = try await harness.twitch.helix(endpoint: .getBannedUsers())

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

    let ban = try await harness.twitch.helix(endpoint: .banUser("9876", in: "5678"))

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

    try await harness.twitch.helix(endpoint: .unbanUser("9876", in: "5678"))
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
      endpoint: .getBlockedTerms(in: "5678"))

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
      endpoint: .addBlockedTerm(in: "5678", text: "A phrase I'm not fond of"))

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
      endpoint: .removeBlockedTerm(in: "5678", termID: "9876"))
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
      endpoint: .deleteChatMessage(in: "5678", messageID: "9876"))
  }

  @Test
  func getModeratedChannels() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/moderation/channels?user_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getModeratedChannelsJSON)

    let (channels, cursor) = try await harness.twitch.helix(
      endpoint: .getModeratedChannels())

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

    let (mods, cursor) = try await harness.twitch.helix(endpoint: .getModerators())

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

    try await harness.twitch.helix(endpoint: .addChannelModerator(userID: "9876"))
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

    try await harness.twitch.helix(endpoint: .removeChannelModerator(userID: "9876"))
  }

  @Test
  func getVIPs() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/channels/vips?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getVIPsJSON)

    let (vips, cursor) = try await harness.twitch.helix(endpoint: .getVIPs())

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

    try await harness.twitch.helix(endpoint: .addChannelVIP(userID: "9876"))
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

    try await harness.twitch.helix(endpoint: .removeChannelVIP(userID: "9876"))
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
      endpoint: .getShieldModeStatus(of: "5678"))

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
      endpoint: .updateShieldModeStatus(of: "5678", isActive: true))

    #expect(result.isActive == true)
    #expect(result.moderatorID == "1234")
  }
}
