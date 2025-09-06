import Testing

@testable import Twitch

@Suite("EventSub Channel Guest Star Events")
struct EventSubGuestStarTests {
  let harness = EventTestHarness()

  @Test("Should decode channelGuestStarSessionBegin event")
  func testChannelGuestStarSessionBeginEvent() async throws {
    let message = try await harness.testEvent(
      .channelGuestStarSessionBegin(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelGuestStarSessionBegin,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelGuestStarSessionEnd event")
  func testChannelGuestStarSessionEndEvent() async throws {
    let message = try await harness.testEvent(
      .channelGuestStarSessionEnd(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelGuestStarSessionEnd,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelGuestStarGuestUpdate event")
  func testChannelGuestStarGuestUpdateEvent() async throws {
    let message = try await harness.testEvent(
      .channelGuestStarGuestUpdate(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelGuestStarGuestUpdate,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelGuestStarSettingsUpdate event")
  func testChannelGuestStarSettingsUpdateEvent() async throws {
    let message = try await harness.testEvent(
      .channelGuestStarSettingsUpdate(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelGuestStarSettingsUpdate,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }
}
