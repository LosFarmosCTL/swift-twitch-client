import Testing

@testable import Twitch

@Suite("EventSub Channel Update Events")
struct UpdateTests {
  let harness = EventTestHarness()

  @Test("Should decode channelUpdate event")
  func testChannelUpdateEvent() async throws {
    let message = try await harness.testEvent(
      .channelUpdate(broadcasterID: "111"),
      with: MockedMessages.channelUpdate,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }
}
