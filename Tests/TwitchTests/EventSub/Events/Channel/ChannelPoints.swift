import Testing

@testable import Twitch

@Suite("EventSub Channel Points Events")
struct EventSubChannelPointsTests {
  let harness = EventTestHarness()

  @Test("Should decode channelPointsCustomRewardAdd event")
  func testChannelPointsCustomRewardAddEvent() async throws {
    let message = try await harness.testEvent(
      .channelPointsCustomRewardAdd(broadcasterID: "1337"),
      with: MockedMessages.channelPointsCustomRewardAdd,
      requiringCondition: ["broadcaster_user_id": "1337"])

    _ = try #require(message)
  }

  @Test("Should decode channelPointsCustomRewardUpdate event")
  func testChannelPointsCustomRewardUpdateEvent() async throws {
    let message = try await harness.testEvent(
      .channelPointsCustomRewardUpdate(broadcasterID: "1337", rewardID: "9001"),
      with: MockedMessages.channelPointsCustomRewardUpdate,
      requiringCondition: [
        "broadcaster_user_id": "1337",
        "reward_id": "9001",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelPointsCustomRewardRemove event")
  func testChannelPointsCustomRewardRemoveEvent() async throws {
    let message = try await harness.testEvent(
      .channelPointsCustomRewardRemove(broadcasterID: "1337", rewardID: "9001"),
      with: MockedMessages.channelPointsCustomRewardRemove,
      requiringCondition: [
        "broadcaster_user_id": "1337",
        "reward_id": "9001",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelPointsCustomRewardRedemptionAdd event")
  func testChannelPointsCustomRewardRedemptionAddEvent() async throws {
    let message = try await harness.testEvent(
      .channelPointsCustomRewardRedemptionAdd(
        broadcasterID: "1337", rewardID: "9001"),
      with: MockedMessages.channelPointsCustomRewardRedemptionAdd,
      requiringCondition: [
        "broadcaster_user_id": "1337",
        "reward_id": "9001",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelPointsCustomRewardRedemptionUpdate event")
  func testChannelPointsCustomRewardRedemptionUpdateEvent() async throws {
    let message = try await harness.testEvent(
      .channelPointsCustomRewardRedemptionUpdate(broadcasterID: "1337", rewardID: "9001"),
      with: MockedMessages.channelPointsCustomRewardRedemptionUpdate,
      requiringCondition: [
        "broadcaster_user_id": "1337",
        "reward_id": "9001",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelPointsAutomaticRewardRedemptionAdd event")
  func testChannelPointsAutomaticRewardRedemptionAddEvent() async throws {
    let message = try await harness.testEvent(
      .channelPointsAutomaticRewardRedemptionAdd(broadcasterID: "1337"),
      with: MockedMessages.channelPointsAutomaticRewardRedemptionAdd,
      requiringCondition: ["broadcaster_user_id": "1337"])

    _ = try #require(message)
  }
}
