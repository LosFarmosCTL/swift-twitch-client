import Testing

@testable import Twitch

@Suite("EventSub VIP Events")
struct EventSubVIPTests {
  let harness = EventTestHarness()

  @Test("Should decode channelVIPAdd event")
  func testChannelVIPAddEvent() async throws {
    let message = try await harness.testEvent(
      .channelVIPAdd(broadcasterID: "1337"),
      with: MockedMessages.channelVIPAdd,
      requiringCondition: ["broadcaster_user_id": "1337"])

    _ = try #require(message)
  }

  @Test("Should decode channelVIPRemove event")
  func testChannelVIPRemoveEvent() async throws {
    let message = try await harness.testEvent(
      .channelVIPRemove(broadcasterID: "1337"),
      with: MockedMessages.channelVIPRemove,
      requiringCondition: ["broadcaster_user_id": "1337"])

    _ = try #require(message)
  }
}
