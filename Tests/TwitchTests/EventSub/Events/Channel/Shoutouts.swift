import Testing

@testable import Twitch

@Suite("EventSub Shoutouts Events")
struct EventSubShoutoutsTests {
  let harness = EventTestHarness()

  @Test("Should decode channelShoutoutCreate event")
  func testChannelShoutoutCreateEvent() async throws {
    let message = try await harness.testEvent(
      .channelShoutoutCreate(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelShoutoutCreate,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelShoutoutReceive event")
  func testChannelShoutoutReceiveEvent() async throws {
    let message = try await harness.testEvent(
      .channelShoutoutReceive(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelShoutoutReceive,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }
}
