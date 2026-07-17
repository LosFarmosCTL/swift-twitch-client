import Foundation
import Testing

@testable import Twitch

struct GoalsTests {
  private let harness = HelixTestHarness()

  @Test
  func getCreatorGoals() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/goals?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getCreatorGoalsJSON)

    let goals = try await harness.twitch.helix(endpoint: .getCreatorGoals())

    #expect(goals.count == 1)
    #expect(goals.first?.id == "1woowvbkiNv8BRxEWSqmQz6Zk92")
    #expect(goals.first?.broadcasterID == "141981764")
    #expect(goals.first?.broadcasterName == "TwitchDev")
    #expect(goals.first?.broadcasterLogin == "twitchdev")
    #expect(goals.first?.type == .follower)
    #expect(goals.first?.description == "Follow goal for Helix testing")
    #expect(goals.first?.currentAmount == 27062)
    #expect(goals.first?.targetAmount == 30000)
    #expect(goals.first?.createdAt.formatted(.iso8601) == "2021-08-16T17:22:23Z")
  }
}
