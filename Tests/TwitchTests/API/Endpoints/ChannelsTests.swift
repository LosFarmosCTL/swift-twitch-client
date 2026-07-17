import Foundation
import Testing

@testable import Twitch

struct ChannelsTests {
  private let harness = HelixTestHarness()

  @Test
  func getChannels() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/channels?broadcaster_id=141981764"))

    await harness.session.stub(
      url: url,
      body: MockedData.getChannelsJSON)

    let channels = try await harness.twitch.helix(
      endpoint: .getChannels(["141981764"])
    )

    #expect(channels.count == 1)
    #expect(channels.contains(where: { $0.id == "141981764" }))

    let channel = channels.first!
    #expect(channel.contentClassificationLabels == [.drugsIntoxication, .sexualThemes])
    #expect(channel.isBrandedContent == false)
  }

  @Test
  func getChannelEditors() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/channels/editors?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getChannelEditorsJSON)

    let editors = try await harness.twitch.helix(endpoint: .getChannelEditors())

    #expect(editors.count == 2)

    #expect(editors.first?.userID == "182891647")
    #expect(editors.last?.userID == "135093069")

    #expect(editors.first?.createdAt.formatted(.iso8601) == "2019-02-15T21:19:50Z")
  }

  @Test
  func getFollowedChannels() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/channels/followed?user_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getFollowedChannelsJSON)

    let result = try await harness.twitch.helix(endpoint: .getFollowedChannels())

    #expect(result.total == 8)

    #expect(result.follows.first?.broadcasterID == "11111")
    #expect(
      result.follows.first?.followedAt.formatted(.iso8601) == "2022-05-24T22:22:08Z")

    #expect(result.cursor == "eyJiIjpudWxsLCJhIjp7Ik9mZnNldCI6NX19")
  }

  @Test
  func checkFollow() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/channels/followed?user_id=1234&broadcaster_id=654321"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.checkFollowJSON)

    let follow = try await harness.twitch.helix(
      endpoint: .checkFollow(to: "654321")
    )

    #expect(follow?.broadcasterID == "654321")
    #expect(follow?.followedAt.formatted(.iso8601) == "2022-05-24T22:22:08Z")
  }

  @Test
  func getChannelFollowers() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/channels/followers?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getChannelFollowersJSON)

    let result = try await harness.twitch.helix(
      endpoint: .getChannelFollowers(of: "1234")
    )

    #expect(result.total == 8)

    #expect(result.followers.first?.userID == "11111")
    #expect(
      result.followers.first?.followedAt.formatted(.iso8601) == "2022-05-24T22:22:08Z")

    #expect(result.cursor == "eyJiIjpudWxsLCJhIjp7Ik9mZnNldCI6NX19")
  }

  @Test
  func checkChannelFollower() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/channels/followers?user_id=654321&broadcaster_id=123456"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.checkChannelFollowerJSON)

    let follow = try await harness.twitch.helix(
      endpoint: .checkFollower("654321", follows: "123456")
    )

    #expect(follow?.userID == "654321")
    #expect(follow?.followedAt.formatted(.iso8601) == "2022-05-24T22:22:08Z")
  }

  @Test
  func updateChannel() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/channels?broadcaster_id=1234"))
    await harness.session.stub(
      url: url,
      method: "PATCH",
      status: 204)

    try await harness.twitch.helix(endpoint: .updateChannel(gameID: "1234"))
  }
}
