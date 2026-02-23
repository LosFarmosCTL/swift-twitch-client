import Testing

@testable import Twitch

@Suite("EventSub Channel Raid Events")
struct RaidTests {
  let harness = EventTestHarness()

  @Test("Should decode channelRaid event from broadcaster")
  func testChannelRaidEventFromBroadcaster() async throws {
    let message = try await harness.testEvent(
      .channelRaid(fromBroadcasterID: "111"),
      with: MockedMessages.channelRaid,
      requiringCondition: ["from_broadcaster_user_id": "111"])

    _ = try #require(message)
  }

  @Test("Should decode channelRaid event to broadcaster")
  func testChannelRaidEventToBroadcaster() async throws {
    let message = try await harness.testEvent(
      .channelRaid(toBroadcasterID: "111"),
      with: MockedMessages.channelRaid,
      requiringCondition: ["to_broadcaster_user_id": "111"])

    _ = try #require(message)
  }
}
