import Testing

@testable import Twitch

@Suite("EventSub Moderation Events")
struct EventSubModerationTests {
  let harness = EventTestHarness()

  @Test("Should decode channelModerate event issuing a warning")
  func testChannelModerateIssueWarningEvent() async throws {
    let message = try await harness.testEvent(
      .channelModerate(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelModerateIssueWarning,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelModerate event timing out a user")
  func testChannelModerateTimeoutUserEvent() async throws {
    let message = try await harness.testEvent(
      .channelModerate(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelModerateTimeoutUser,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelModerate event timing out a user in a shared chat")
  func testChannelModerateTimeoutUserSharedChatEvent() async throws {
    let message = try await harness.testEvent(
      .channelModerate(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelModerateTimeoutUserSharedChat,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelModerate event setting emote only mode")
  func testChannelModerateEmoteOnlyModeEvent() async throws {
    let message = try await harness.testEvent(
      .channelModerate(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelModerateEmoteOnlyMode,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelModerate event adding a moderator")
  func testChannelModerateAddModeratorEvent() async throws {
    let message = try await harness.testEvent(
      .channelModerate(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelModerateAddModerator,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelBan event")
  func testChannelBanEvent() async throws {
    let message = try await harness.testEvent(
      .channelBan(broadcasterID: "111"),
      with: MockedMessages.channelBan,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }

  @Test("Should decode channelUnban event")
  func testChannelUnbanEvent() async throws {
    let message = try await harness.testEvent(
      .channelUnban(broadcasterID: "111"),
      with: MockedMessages.channelUnban,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }

  @Test("Should decode channelModeratorAdd event")
  func testChannelModeratorAddEvent() async throws {
    let message = try await harness.testEvent(
      .channelModeratorAdd(broadcasterID: "111"),
      with: MockedMessages.channelModeratorAdd,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }

  @Test("Should decode channelModeratorRemove event")
  func testChannelModeratorRemoveEvent() async throws {
    let message = try await harness.testEvent(
      .channelModeratorRemove(broadcasterID: "111"),
      with: MockedMessages.channelModeratorRemove,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }

  @Test("Should decode channelShieldModeBegin event")
  func testChannelShieldModeBeginEvent() async throws {
    let message = try await harness.testEvent(
      .channelShieldModeBegin(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelShieldModeBegin,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelShieldModeEnd event")
  func testChannelShieldModeEndEvent() async throws {
    let message = try await harness.testEvent(
      .channelShieldModeEnd(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelShieldModeEnd,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelSuspiciousUserMessage event")
  func testChannelSuspiciousUserMessageEvent() async throws {
    let message = try await harness.testEvent(
      .channelSuspiciousUserMessage(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelSuspiciousUserMessage,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelSuspiciousUserUpdate event")
  func testChannelSuspiciousUserUpdateEvent() async throws {
    let message = try await harness.testEvent(
      .channelSuspiciousUserUpdate(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelSuspiciousUserUpdate,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelUnbanRequestCreate event")
  func testChannelUnbanRequestCreateEvent() async throws {
    let message = try await harness.testEvent(
      .channelUnbanRequestCreate(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelUnbanRequestCreate,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelUnbanRequestResolve event")
  func testChannelUnbanRequestResolveEvent() async throws {
    let message = try await harness.testEvent(
      .channelUnbanRequestResolve(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelUnbanRequestResolve,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelWarningAcknowledge event")
  func testChannelWarningAcknowledgeEvent() async throws {
    let message = try await harness.testEvent(
      .channelWarningAcknowledge(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelWarningAcknowledge,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }

  @Test("Should decode channelWarningSend event")
  func testChannelWarningSendEvent() async throws {
    let message = try await harness.testEvent(
      .channelWarningSend(broadcasterID: "111", moderatorID: "222"),
      with: MockedMessages.channelWarningSend,
      requiringCondition: [
        "broadcaster_user_id": "111",
        "moderator_user_id": "222",
      ])

    _ = try #require(message)
  }
}
