import Testing

@testable import Twitch

@Suite("EventSub Shared Chat Events")
struct EventSubSharedChatTests {
  let harness = EventTestHarness()

  @Test("Should decode channelSharedChatSessionBegin event")
  func testChannelSharedChatSessionBeginEvent() async throws {
    let message = try await harness.testEvent(
      .channelSharedChatSessionBegin(broadcasterID: "111"),
      with: MockedMessages.channelSharedChatSessionBegin,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }

  @Test("Should decode channelSharedChatSessionUpdate event")
  func testChannelSharedChatSessionUpdateEvent() async throws {
    let message = try await harness.testEvent(
      .channelSharedChatSessionUpdate(broadcasterID: "111"),
      with: MockedMessages.channelSharedChatSessionUpdate,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }

  @Test("Should decode channelSharedChatSessionEnd event")
  func testChannelSharedChatSessionEndEvent() async throws {
    let message = try await harness.testEvent(
      .channelSharedChatSessionEnd(broadcasterID: "111"),
      with: MockedMessages.channelSharedChatSessionEnd,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }
}
