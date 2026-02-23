import Testing

@testable import Twitch

@Suite("EventSub Channel Ads Events")
struct EventSubAdsTests {
  let harness = EventTestHarness()

  @Test("Should decode channelAdBreakBegin event")
  func testChannelAdBreakBeginEvent() async throws {
    let message = try await harness.testEvent(
      .channelAdBreakBegin(broadcasterID: "111"),
      with: MockedMessages.channelAdBreakBegin,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }
}
