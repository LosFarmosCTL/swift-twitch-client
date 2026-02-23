import Testing

@testable import Twitch

@Suite("EventSub Channel Follow Events")
struct FollowTests {
  let harness = EventTestHarness()

  @Test("Should decode channelFollow event")
  func testChannelFollowEvent() async throws {
    let message = try await harness.testEvent(
      .channelFollow(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelFollow,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }
}
