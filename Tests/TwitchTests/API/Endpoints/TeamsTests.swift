import Foundation
import Testing

@testable import Twitch

struct TeamsTests {
  private let harness = HelixTestHarness()

  @Test
  func getChannelTeams() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/teams/channel?broadcaster_id=96909659"))

    await harness.session.stub(
      url: url,
      body: MockedData.getChannelTeamsJSON)

    let teams = try await harness.twitch.helix(
      endpoint: .getChannelTeams(for: "96909659")
    )

    #expect(teams.count == 1)
    #expect(teams.first?.id == "6358")
    #expect(teams.first?.teamDisplayName == "Live Coders")
    #expect(teams.first?.createdAt.formatted(.iso8601) == "2019-02-11T12:09:22Z")
  }

  @Test
  func getTeams() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/teams?id=6358"))

    await harness.session.stub(
      url: url,
      body: MockedData.getTeamsJSON)

    let teams = try await harness.twitch.helix(endpoint: .getTeams(id: "6358"))

    #expect(teams.count == 1)
    #expect(teams.first?.teamName == "livecoders")
    #expect(teams.first?.users?.count == 2)
    #expect(teams.first?.users?.first?.userID == "278217731")
  }
}
