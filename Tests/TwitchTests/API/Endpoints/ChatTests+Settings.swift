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
    #expect(settings.slowMode == true)
    #expect(settings.slowModeWaitTime == 5)
    #expect(settings.followerMode == true)
    #expect(settings.followerModeDuration == 0)
    #expect(settings.subscriberMode == true)
    #expect(settings.emoteMode == false)
    #expect(settings.uniqueChatMode == false)
    #expect(settings.nonModeratorChatDelay == true)
    #expect(settings.nonModeratorChatDelayDuration == 4)
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
          of: "713936733",
          settings: .init(
            slowMode: true, slowModeWaitTime: 5, followerMode: true, subscriberMode: true))))
      .value

    #expect(settings.broadcasterID == "713936733")
    #expect(settings.slowMode == true)
    #expect(settings.slowModeWaitTime == 5)
    #expect(settings.followerMode == true)
    #expect(settings.followerModeDuration == 0)
    #expect(settings.subscriberMode == true)
    #expect(settings.emoteMode == false)
    #expect(settings.uniqueChatMode == false)
    #expect(settings.nonModeratorChatDelay == true)
    #expect(settings.nonModeratorChatDelayDuration == 4)
  }

  @Test
  func chatSettingsPatchSendsExplicitFlagsAndOmitsUnspecifiedFields() async throws {
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
        settings: .init(
          slowMode: false, followerMode: false, subscriberMode: false,
          emoteMode: false, uniqueChatMode: false, nonModeratorChatDelay: false)))
    let disabledBody = try #require(await harness.session.lastRequest()?.httpBody)
    #expect(
      try JSONDecoder().decode([String: Bool].self, from: disabledBody) == [
        "slow_mode": false, "follower_mode": false, "subscriber_mode": false,
        "emote_mode": false, "unique_chat_mode": false, "non_moderator_chat_delay": false,
      ])

    _ = try await harness.twitch.helix(
      for: .updateChatSettings(
        of: "channel",
        settings: .init(slowMode: false, followerMode: true, followerModeDuration: 0)))
    let body = try #require(await harness.session.lastRequest()?.httpBody)
    let fields = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
    #expect(fields.count == 3)
    #expect(fields["slow_mode"] as? Bool == false)
    #expect(fields["follower_mode"] as? Bool == true)
    #expect(fields["follower_mode_duration"] as? Int == 0)
  }

  @Test
  func durationFieldsDoNotImplicitlyEnableModes() throws {
    let patch = ChatSettingsUpdate(
      slowModeWaitTime: 5, followerModeDuration: 0, nonModeratorChatDelayDuration: 4)
    let data = try TwitchClient.makeEncoder().encode(patch)
    let fields = try JSONDecoder().decode([String: Int].self, from: data)
    #expect(
      fields == [
        "slow_mode_wait_time": 5, "follower_mode_duration": 0,
        "non_moderator_chat_delay_duration": 4,
      ])
  }
}
