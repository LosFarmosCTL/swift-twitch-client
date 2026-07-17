import Foundation
import Testing

@testable import Twitch

struct RaidsTests {
  private let harness = HelixTestHarness()

  @Test
  func startRaid() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/raids?from_broadcaster_id=1234&to_broadcaster_id=5678"
      ))

    await harness.session.stub(
      url: url,
      method: "POST",
      body: MockedData.startRaidJSON)

    let raid = try await harness.twitch.helix(endpoint: .startRaid(to: "5678"))

    #expect(raid.createdAt.formatted(.iso8601) == "2022-02-18T07:20:50Z")
    #expect(raid.isMature == false)
  }

  @Test
  func cancelRaid() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/raids?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      method: "DELETE",
      status: 204)

    try await harness.twitch.helix(endpoint: .cancelRaid())
  }
}
