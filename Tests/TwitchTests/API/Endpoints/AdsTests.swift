import Foundation
import Testing

@testable import Twitch

struct AdsTests {
  private let harness = HelixTestHarness()

  @Test
  func getAdSchedule() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/channels/ads?broadcaster_id=1234"))

    await harness.session.stub(url: url, body: MockedData.getAdScheduleJSON)

    let ads = try await harness.twitch.helix(endpoint: .getAdSchedule())

    #expect(ads.count == 1)

    #expect(ads.first?.duration == 60)
    #expect(ads.first?.nextAdAt.formatted(.iso8601) == "2023-08-01T23:08:18Z")
  }

  @Test
  func startCommercial() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/channels/commercial"))

    await harness.session.stub(
      url: url,
      method: "POST",
      body: MockedData.startCommercialJSON)

    let commercial = try await harness.twitch.helix(
      endpoint: .startCommercial(length: 60)
    )

    #expect(commercial.length == 60)
    #expect(commercial.message == "")
    #expect(commercial.retryAfter == 480)
  }

  @Test
  func snoozeNextAd() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/channels/ads/schedule/snooze?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      method: "POST",
      body: MockedData.snoozeNextAdJSON)

    let snoozeResult = try await harness.twitch.helix(endpoint: .snoozeNextAd())

    #expect(snoozeResult.snoozeCount == 1)
    #expect(
      snoozeResult.snoozeRefreshAt.formatted(.iso8601) == "2023-08-01T23:08:18Z")
  }
}
