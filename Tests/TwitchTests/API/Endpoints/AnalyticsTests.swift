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

    let (analytics, _) = try await harness.twitch.helix(
      endpoint: .getExtensionAnalytics())

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

    let (analytics, _) = try await harness.twitch.helix(endpoint: .getGameAnalytics())

    #expect(analytics.count == 1)

    #expect(analytics.contains(where: { $0.gameID == "9821" }))

    #expect(analytics.first?.range.start.formatted(.iso8601) == "2018-03-13T00:00:00Z")
    #expect(analytics.first?.range.end.formatted(.iso8601) == "2018-06-13T00:00:00Z")
  }
}
