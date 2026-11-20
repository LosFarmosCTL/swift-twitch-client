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

  @Test("Should decode a custom Power-up purchase in Bits Use")
  func customPowerUpBitsUse() async throws {
    let fixture = MockedMessages.channelBitsUse.replacingOccurrences(
      of: #""type": "cheer","#,
      with:
        #""type": "custom_power_up", "custom_power_up": {"title":"Party","reward_id":"reward"},"#)
    let event = try #require(
      try await harness.testEvent(
        .channelBitsUse(broadcasterID: "111"),
        with: fixture,
        requiringCondition: ["broadcaster_user_id": "111"]))
    guard case .customPowerUp(let powerUp) = event.type else {
      Issue.record("Expected a custom Power-up")
      return
    }
    #expect(powerUp.rewardID == "reward")
  }

  @Test("Should receive a custom Power-up redemption for the selected reward")
  func customPowerUpRedemption() async throws {
    let event = try #require(
      try await harness.testEvent(
        .channelCustomPowerUpRedemptionAdd(broadcasterID: "1337", rewardID: "reward"),
        with: MockedMessages.channelCustomPowerUpRedemptionAdd,
        requiringCondition: ["broadcaster_user_id": "1337", "reward_id": "reward"]))
    #expect(event.customPowerUp.id == "reward")
    #expect(event.customPowerUp.bits == 100)
  }
}
