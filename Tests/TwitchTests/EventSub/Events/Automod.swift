import Foundation
import Testing

@testable import Twitch

@Suite("EventSub Automod Events")
struct AutomodTests {
  let harness = EventTestHarness()

  @Test("Should decode automodMessageHold event")
  func testAutomodMessageHoldEvent() async throws {
    let message = try await harness.testEvent(
      .automodMessageHold(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.automodMessageHold,
      requiringCondition: ["broadcaster_user_id": "111", "moderator_user_id": "222"])

    _ = try #require(message)
  }

  @Test("Should decode automodMessageUpdate event")
  func testAutomodMessageUpdateEvent() async throws {
    let message = try await harness.testEvent(
      .automodMessageUpdate(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.automodMessageUpdate,
      requiringCondition: ["broadcaster_user_id": "111", "moderator_user_id": "222"])

    _ = try #require(message)
  }

  @Test("Should decode automodSettingUpdate event")
  func testAutomodSettingUpdateEvent() async throws {
    let message = try await harness.testEvent(
      .automodSettingsUpdate(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.automodSettingsUpdate,
      requiringCondition: ["broadcaster_user_id": "111", "moderator_user_id": "222"])

    _ = try #require(message)
  }

  @Test("Should decode automodTermsUpdate event")
  func testAutomodTermsUpdateEvent() async throws {
    let message = try await harness.testEvent(
      .automodTermsUpdate(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.automodTermsUpdate,
      requiringCondition: ["broadcaster_user_id": "111", "moderator_user_id": "222"])

    _ = try #require(message)
  }
}
