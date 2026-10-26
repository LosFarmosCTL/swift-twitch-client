import Foundation
import Testing

@testable import Twitch

@Suite("EventSub Automod Events")
struct AutoModTests {
  let harness = EventTestHarness()

  @Test("Should decode automodMessageHold event")
  func testAutoModMessageHoldEvent() async throws {
    let message = try await harness.testEvent(
      .autoModMessageHold(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.autoModMessageHold,
      requiringCondition: ["broadcaster_user_id": "111", "moderator_user_id": "222"])

    _ = try #require(message)
  }

  @Test("Should decode automodMessageUpdate event")
  func testAutoModMessageUpdateEvent() async throws {
    let message = try await harness.testEvent(
      .autoModMessageUpdate(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.autoModMessageUpdate,
      requiringCondition: ["broadcaster_user_id": "111", "moderator_user_id": "222"])

    _ = try #require(message)
  }

  @Test("Should decode automodSettingUpdate event")
  func testAutoModSettingUpdateEvent() async throws {
    let message = try await harness.testEvent(
      .autoModSettingsUpdate(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.autoModSettingsUpdate,
      requiringCondition: ["broadcaster_user_id": "111", "moderator_user_id": "222"])

    _ = try #require(message)
  }

  @Test("Should decode automodTermsUpdate event")
  func testAutoModTermsUpdateEvent() async throws {
    let message = try await harness.testEvent(
      .autoModTermsUpdate(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.autoModTermsUpdate,
      requiringCondition: ["broadcaster_user_id": "111", "moderator_user_id": "222"])

    _ = try #require(message)
  }
}
