import Foundation
import Testing

@testable import Twitch

extension ManagedChatEventSubTests {
  @Test(arguments: [true, false])
  func settingsSnapshotUsesEnabledFlags(enabled: Bool) async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/chat/settings?broadcaster_id=123"))
    let body = Data(
      """
      {"data":[{"broadcaster_id":"123","slow_mode":\(enabled),"slow_mode_wait_time":10,
      "follower_mode":\(enabled),"follower_mode_duration":0,"subscriber_mode":false,
      "emote_mode":false,"unique_chat_mode":false}]}
      """.utf8)
    await session.stub(url: url, body: body)

    let client = await client()
    try await client.join(to: channel)
    let state = try #require(
      await client.chatStateUpdates().first {
        $0.channels[self.channel.id]?.settings.isKnown == true
      })
    let settings = try #require(state.channels[channel.id]?.settings)
    #expect(settings.slowMode == (enabled ? .seconds(10) : nil))
    #expect(settings.followersOnly == (enabled ? .zero : nil))
    await client.shutdownChat()
    await client.resetEventSub()
  }
}
