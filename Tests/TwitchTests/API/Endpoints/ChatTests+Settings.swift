import Foundation
import Testing

@testable import Twitch

extension ChatTests {
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

    let settings =
      (try await harness.twitch.helix(
        for: .getChatSettings(of: "713936733", moderatorID: "1234"))).value

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

    let settings =
      (try await harness.twitch.helix(
        for: .updateChatSettings(
          of: "713936733", settings: .slowMode(5), .subscriberMode, .followerMode())))
      .value

    #expect(settings.broadcasterID == "713936733")
    #expect(settings.slowModeWaitTime == 5)
    #expect(settings.followerModeDuration == 0)
    #expect(settings.subscriberMode == true)
    #expect(settings.emoteMode == false)
    #expect(settings.uniqueChatMode == false)
    #expect(settings.nonModeratorChatDelay == 4)
  }

  @Test
  func disablingChatModesClearsDurationsAndLeavesOmittedSettingsOut() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/chat/settings?broadcaster_id=channel&moderator_id=1234"
      ))
    await harness.session.stub(
      url: url, method: "PATCH", body: MockedData.getChatSettingsJSON)

    _ = try await harness.twitch.helix(
      for: .updateChatSettings(
        of: "channel",
        settings: [
          .slowMode(10), .disable(.slowMode),
          .followerMode(20), .disable(.followerMode),
          .disable(.subscriberMode), .disable(.emoteMode), .disable(.uniqueChatMode),
          .nonModeratorChatDelay(4), .disable(.nonModeratorChatDelay),
        ]))
    let disabledBody = try #require(await harness.session.lastRequest()?.httpBody)
    #expect(
      try JSONDecoder().decode([String: Bool].self, from: disabledBody) == [
        "slow_mode": false, "follower_mode": false, "subscriber_mode": false,
        "emote_mode": false, "unique_chat_mode": false, "non_moderator_chat_delay": false,
      ])

    _ = try await harness.twitch.helix(
      for: .updateChatSettings(
        of: "channel", settings: .disable(.slowMode), .slowMode(5)))
    let enabledBody = try #require(await harness.session.lastRequest()?.httpBody)
    let fields = try #require(
      JSONSerialization.jsonObject(with: enabledBody) as? [String: Any])
    #expect(fields.count == 2)
    #expect(fields["slow_mode"] as? Bool == true)
    #expect(fields["slow_mode_wait_time"] as? Int == 5)
  }
}
