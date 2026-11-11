import Foundation
import Testing

@testable import Twitch

extension ModerationTests {
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

    let result =
      (try await harness.twitch.helix(
        for: .getShieldModeStatus(of: "5678"))).value

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

    let result =
      (try await harness.twitch.helix(
        for: .updateShieldModeStatus(of: "5678", isActive: true))).value

    #expect(result.isActive == true)
    #expect(result.moderatorID == "1234")
  }
}
