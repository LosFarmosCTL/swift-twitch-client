import Foundation
import Testing

@testable import Twitch

struct AnalyticsTests {
  private let harness = HelixTestHarness()

  @Test
  func getExtensionAnalytics() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/analytics/extensions"))

    await harness.session.stub(
      url: url,
      body: MockedData.getExtensionAnalyticsJSON)

    let page =
      (try await harness.twitch.helix(
        for: .getExtensionAnalytics())).value
    let analytics = page.reports

    #expect(analytics.count == 1)
    #expect(analytics.contains(where: { $0.extensionID == "efgh" }))

    #expect(analytics.first?.range.start.formatted(.iso8601) == "2018-03-01T00:00:00Z")
    #expect(analytics.first?.range.end.formatted(.iso8601) == "2018-06-01T00:00:00Z")
  }

  @Test
  func getGameAnalytics() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/analytics/games"))

    await harness.session.stub(
      url: url,
      body: MockedData.getGameAnalyticsJSON)

    let page = (try await harness.twitch.helix(for: .getGameAnalytics())).value
    let analytics = page.reports

    #expect(analytics.count == 1)

    #expect(analytics.contains(where: { $0.gameID == "9821" }))

    #expect(analytics.first?.range.start.formatted(.iso8601) == "2018-03-13T00:00:00Z")
    #expect(analytics.first?.range.end.formatted(.iso8601) == "2018-06-13T00:00:00Z")
  }

  @Test
  func invertedAnalyticsDateRangeFailsDecodingInsteadOfTrapping() async throws {
    let invertedExtension = Data(
      """
      {"data":[{"extension_id":"efgh","URL":"https://example.com","type":"overview_v2",\
      "date_range":{"started_at":"2018-06-01T00:00:00Z","ended_at":"2018-03-01T00:00:00Z"}}]}
      """.utf8)
    let invertedGame = Data(
      """
      {"data":[{"game_id":"9821","URL":"https://example.com","type":"overview_v2",\
      "date_range":{"started_at":"2018-06-13T00:00:00Z","ended_at":"2018-03-13T00:00:00Z"}}]}
      """.utf8)

    await harness.session.stub(
      url: URL(string: "https://api.twitch.tv/helix/analytics/extensions")!,
      body: invertedExtension)
    await harness.session.stub(
      url: URL(string: "https://api.twitch.tv/helix/analytics/games")!,
      body: invertedGame)

    let extensionError = await #expect(throws: HelixError.self) {
      try await harness.twitch.helix(for: .getExtensionAnalytics())
    }
    #expect({ if case .parsingResponseFailed = extensionError { true } else { false } }())

    let gameError = await #expect(throws: HelixError.self) {
      try await harness.twitch.helix(for: .getGameAnalytics())
    }
    #expect({ if case .parsingResponseFailed = gameError { true } else { false } }())
  }
}
