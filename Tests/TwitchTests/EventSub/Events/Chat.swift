import Testing

@testable import Twitch

@Suite("EventSub Chat Events")
struct EventSubChatTests {
  let harness = EventTestHarness()

  @Test("Should decode channelChatClear event")
  func testChannelChatClearEvent() async throws {
    let message = try await harness.testEvent(
      .chatClear(broadcasterID: "111", userID: "222"),
      with: MockedMessages.channelChatClear,
      requiringCondition: ["broadcaster_user_id": "111", "user_id": "222"])

    _ = try #require(message)
  }

  @Test("Should decode channelChatClearUserMessages event")
  func testChannelChatClearUserMessagesEvent() async throws {
    let message = try await harness.testEvent(
      .chatClearUserMessages(broadcasterID: "111", userID: "222"),
      with: MockedMessages.channelChatClearUserMessages,
      requiringCondition: ["broadcaster_user_id": "111", "user_id": "222"])

    _ = try #require(message)
  }

  // TODO: needs some more testing for various types of messages
  @Test("Should decode channelChatMessage event")
  func testChannelChatMessageEvent() async throws {
    let message = try await harness.testEvent(
      .chatMessage(broadcasterID: "111", userID: "222"),
      with: MockedMessages.channelChatMessage,
      requiringCondition: ["broadcaster_user_id": "111", "user_id": "222"])

    _ = try #require(message)
  }

  @Test("Should decode channelChatMessageDelete event")
  func testChannelChatMessageDeleteEvent() async throws {
    let message = try await harness.testEvent(
      .channelChatMessageDelete(broadcasterID: "111", userID: "222"),
      with: MockedMessages.channelChatMessageDelete,
      requiringCondition: ["broadcaster_user_id": "111", "user_id": "222"])

    _ = try #require(message)
  }

  @Test("Should decode channelChatNotification event")
  func testChannelChatNotificationEvent() async throws {
    let message = try await harness.testEvent(
      .channelChatNotification(broadcasterID: "111", userID: "222"),
      with: MockedMessages.channelChatNotification,
      requiringCondition: ["broadcaster_user_id": "111", "user_id": "222"])

    let received = try #require(message)
    guard case .resub(let notice) = received.noticeType else {
      Issue.record("Expected resub notice type, got \(received.noticeType)")
      return
    }

    #expect(notice.subTier == .tier1)
    #expect(notice.isPrime == false)
    #expect(notice.durationMonths == 1)
    #expect(notice.cumulativeMonths == 10)
    #expect(notice.streakMonths == nil)
    #expect(notice.gift == nil)
  }

  @Test("Should decode channelChatNotification event in shared chat")
  func testChannelChatNotificationSharedChatEvent() async throws {
    let message = try await harness.testEvent(
      .channelChatNotification(broadcasterID: "111", userID: "222"),
      with: MockedMessages.channelChatNotificationSharedChat,
      requiringCondition: ["broadcaster_user_id": "111", "user_id": "222"])

    let received = try #require(message)
    guard case .sharedChatResub(let notice) = received.noticeType else {
      Issue.record("Expected shared chat resub notice type, got \(received.noticeType)")
      return
    }

    #expect(notice.subTier == .tier1)
    #expect(notice.isPrime == false)
    #expect(notice.durationMonths == 1)
    #expect(notice.cumulativeMonths == 10)
    #expect(notice.streakMonths == nil)
    #expect(notice.gift == nil)
  }

  @Test("Should decode channelChatSettingsUpdate event")
  func testChannelChatSettingsUpdateEvent() async throws {
    let message = try await harness.testEvent(
      .channelChatSettingsUpdate(broadcasterID: "111", userID: "222"),
      with: MockedMessages.channelChatSettingsUpdate,
      requiringCondition: ["broadcaster_user_id": "111", "user_id": "222"])

    _ = try #require(message)
  }

  @Test("Should decode channelChatUserMessageHold event")
  func testChannelChatUserMessageHoldEvent() async throws {
    let message = try await harness.testEvent(
      .channelChatUserMessageHold(broadcasterID: "111", userID: "222"),
      with: MockedMessages.channelChatUserMessageHold,
      requiringCondition: ["broadcaster_user_id": "111", "user_id": "222"])

    _ = try #require(message)
  }

  @Test("Should decode channelChatUserMessageUpdate event")
  func testChannelChatUserMessageUpdateEvent() async throws {
    let message = try await harness.testEvent(
      .channelChatUserMessageUpdate(broadcasterID: "111", userID: "222"),
      with: MockedMessages.channelChatUserMessageUpdate,
      requiringCondition: ["broadcaster_user_id": "111", "user_id": "222"])

    _ = try #require(message)
  }
}
