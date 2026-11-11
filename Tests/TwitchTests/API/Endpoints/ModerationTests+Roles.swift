import Foundation
import Testing

@testable import Twitch

extension ModerationTests {
  @Test
  func getModeratedChannels() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/moderation/channels?user_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getModeratedChannelsJSON)

    let (channels, cursor) =
      (try await harness.twitch.helix(
        for: .getModeratedChannels())).value

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

    let (mods, cursor) = (try await harness.twitch.helix(for: .getModerators())).value

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

    let (vips, cursor) = (try await harness.twitch.helix(for: .getVIPs())).value

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
}
