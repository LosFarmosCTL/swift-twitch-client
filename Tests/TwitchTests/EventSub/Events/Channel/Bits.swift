import Foundation
import Testing

@testable import Twitch

@Suite("EventSub Channel Bits Events")
struct EventSubBitsTests {
  let harness = EventTestHarness()

  @Test("Should decode channelBitsUse event")
  func testChannelBitsUseEvent() async throws {
    let message = try await harness.testEvent(
      .channelBitsUse(broadcasterID: "111"),
      with: MockedMessages.channelBitsUse,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }

  @Test("Should decode channelCheer event")
  func testChannelCheerEvent() async throws {
    let message = try await harness.testEvent(
      .channelCheer(broadcasterID: "111"),
      with: MockedMessages.channelCheer,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }
}
