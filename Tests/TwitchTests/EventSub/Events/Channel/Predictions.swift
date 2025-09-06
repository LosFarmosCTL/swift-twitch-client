import Testing

@testable import Twitch

@Suite("EventSub Predictions Events")
struct EventSubPredictionsTests {
  let harness = EventTestHarness()

  @Test("Should decode channelPredictionBegin event")
  func testChannelPredictionBeginEvent() async throws {
    let message = try await harness.testEvent(
      .channelPredictionBegin(broadcasterID: "1337"),
      with: MockedMessages.channelPredictionBegin,
      requiringCondition: ["broadcaster_user_id": "1337"])

    _ = try #require(message)
  }

  @Test("Should decode channelPredictionProgress event")
  func testChannelPredictionProgressEvent() async throws {
    let message = try await harness.testEvent(
      .channelPredictionProgress(broadcasterID: "1337"),
      with: MockedMessages.channelPredictionProgress,
      requiringCondition: ["broadcaster_user_id": "1337"])

    _ = try #require(message)
  }

  @Test("Should decode channelPredictionLock event")
  func testChannelPredictionLockEvent() async throws {
    let message = try await harness.testEvent(
      .channelPredictionLock(broadcasterID: "1337"),
      with: MockedMessages.channelPredictionLock,
      requiringCondition: ["broadcaster_user_id": "1337"])

    _ = try #require(message)
  }

  @Test("Should decode channelPredictionEnd event")
  func testChannelPredictionEndEvent() async throws {
    let message = try await harness.testEvent(
      .channelPredictionEnd(broadcasterID: "1337"),
      with: MockedMessages.channelPredictionEnd,
      requiringCondition: ["broadcaster_user_id": "1337"])

    _ = try #require(message)
  }
}
