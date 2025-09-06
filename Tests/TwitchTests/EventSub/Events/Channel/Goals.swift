import Testing

@testable import Twitch

@Suite("EventSub Goals Events")
struct EventSubGoalsTests {
  let harness = EventTestHarness()

  @Test("Should decode goalBegin event")
  func testChannelGoalBeginEvent() async throws {
    let message = try await harness.testEvent(
      .channelGoalBegin(broadcasterID: "111"),
      with: MockedMessages.channelGoalBegin,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }

  @Test("Should decode goalProgress event")
  func testChannelGoalProgressEvent() async throws {
    let message = try await harness.testEvent(
      .channelGoalProgress(broadcasterID: "111"),
      with: MockedMessages.channelGoalProgress,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }

  @Test("Should decode goalEnd event")
  func testChannelGoalEndEvent() async throws {
    let message = try await harness.testEvent(
      .channelGoalEnd(broadcasterID: "111"),
      with: MockedMessages.channelGoalEnd,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }
}
