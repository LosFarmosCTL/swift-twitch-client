import Testing

@testable import Twitch

@Suite("EventSub HypeTrain Events")
struct EventSubHypeTrainTests {
  let harness = EventTestHarness()

  @Test("Should decode channelHypeTrainBegin event")
  func testChannelHypeTrainBeginEvent() async throws {
    let message = try await harness.testEvent(
      .channelHypeTrainBegin(broadcasterID: "111"),
      with: MockedMessages.channelHypeTrainBegin,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }

  @Test("Should decode channelHypeTrainProgress event")
  func testChannelHypeTrainProgressEvent() async throws {
    let message = try await harness.testEvent(
      .channelHypeTrainProgress(broadcasterID: "111"),
      with: MockedMessages.channelHypeTrainProgress,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }

  @Test("Should decode channelHypeTrainEnd event")
  func testChannelHypeTrainEndEvent() async throws {
    let message = try await harness.testEvent(
      .channelHypeTrainEnd(broadcasterID: "111"),
      with: MockedMessages.channelHypeTrainEnd,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }
}
