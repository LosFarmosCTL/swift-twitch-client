import Foundation
import Testing

@testable import Twitch

extension ModerationTests {
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

    let result =
      (try await harness.twitch.helix(
        for: .checkAutoModStatus(
          messages: ("123", "This is a test message."),
          ("393", "This is another test message."))
      )).value

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

    let result = (try await harness.twitch.helix(for: .getAutoModSettings(of: "5678")))
      .value

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

    let result =
      (try await harness.twitch.helix(
        for: .updateAutoModSettings(of: "5678", overall: 3))).value

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
}
