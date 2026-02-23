import Testing

@testable import Twitch

@Suite("EventSub Polls Events")
struct EventSubPollsTests {
  let harness = EventTestHarness()

  @Test("Should decode channelPollBegin event")
  func testChannelPollBeginEvent() async throws {
    let message = try await harness.testEvent(
      .channelPollBegin(broadcasterID: "1337"),
      with: MockedMessages.channelPollBegin,
      requiringCondition: ["broadcaster_user_id": "1337"])

    _ = try #require(message)
  }

  @Test("Should decode channelPollProgress event")
  func testChannelPollProgressEvent() async throws {
    let message = try await harness.testEvent(
      .channelPollProgress(broadcasterID: "1337"),
      with: MockedMessages.channelPollProgress,
      requiringCondition: ["broadcaster_user_id": "1337"])

    _ = try #require(message)
  }

  @Test("Should decode channelPollEnd event")
  func testChannelPollEndEvent() async throws {
    let message = try await harness.testEvent(
      .channelPollEnd(broadcasterID: "1337"),
      with: MockedMessages.channelPollEnd,
      requiringCondition: ["broadcaster_user_id": "1337"])

    _ = try #require(message)
  }
}
