import Foundation
import Testing

@testable import Twitch

struct GamesTests {
  private let harness = HelixTestHarness()

  @Test
  func getGames() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/games?id=33214"))

    await harness.session.stub(
      url: url,
      body: MockedData.getGamesJSON)

    let games = try await harness.twitch.helix(endpoint: .getGames(gameIDs: ["33214"]))

    #expect(games.count == 1)
    #expect(games.contains(where: { $0.id == "33214" }))
  }

  @Test
  func getTopGames() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/games/top?first=1"))

    await harness.session.stub(
      url: url,
      body: MockedData.getTopGamesJSON)

    let (games, cursor) = try await harness.twitch.helix(endpoint: .getTopGames(limit: 1))

    #expect(cursor == "eyJiIjpudWxsLCJhIjp7Ik9mZnNldCI6MjB9fQ==")

    #expect(games.count == 1)
    #expect(games.contains(where: { $0.id == "493057" }))
  }
}
