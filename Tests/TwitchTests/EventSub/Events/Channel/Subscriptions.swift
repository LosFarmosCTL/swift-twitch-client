import Testing

@testable import Twitch

@Suite("EventSub Subscription Events")
struct EventSubSubscriptionTests {
  let harness = EventTestHarness()

  @Test("Should decode channelSubscribe event")
  func testChannelSubscribeEvent() async throws {
    let message = try await harness.testEvent(
      .channelSubscribe(broadcasterID: "111"),
      with: MockedMessages.channelSubscribe,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }

  @Test("Should decode channelSubscriptionEnd event")
  func testChannelSubscriptionEndEvent() async throws {
    let message = try await harness.testEvent(
      .channelSubscriptionEnd(broadcasterID: "111"),
      with: MockedMessages.channelSubscriptionEnd,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }

  @Test("Should decode channelSubscriptionGift event")
  func testChannelSubscriptionGiftEvent() async throws {
    let message = try await harness.testEvent(
      .channelSubscriptionGift(broadcasterID: "111"),
      with: MockedMessages.channelSubscriptionGift,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }

  @Test("Should decode channelSubscriptionMessage event")
  func testChannelSubscriptionMessageEvent() async throws {
    let message = try await harness.testEvent(
      .channelSubscriptionMessage(broadcasterID: "111"),
      with: MockedMessages.channelSubscriptionMessage,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }
}
