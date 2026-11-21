import Foundation
import Testing

@testable import Twitch

@Suite("EventSub Chat Events")
struct EventSubChatTests {
  let harness = EventTestHarness()

  @Test("Should decode channelChatClear event")
  func testChannelChatClearEvent() async throws {
    let message = try await harness.testEvent(
      .channelChatClear(broadcasterID: "111", userID: "222"),
      with: MockedMessages.channelChatClear,
      requiringCondition: ["broadcaster_user_id": "111", "user_id": "222"])

    _ = try #require(message)
  }

  @Test("Should decode channelChatClearUserMessages event")
  func testChannelChatClearUserMessagesEvent() async throws {
    let message = try await harness.testEvent(
      .channelChatClearUserMessages(broadcasterID: "111", userID: "222"),
      with: MockedMessages.channelChatClearUserMessages,
      requiringCondition: ["broadcaster_user_id": "111", "user_id": "222"])

    _ = try #require(message)
  }

  // TODO: needs some more testing for various types of messages
  @Test("Should decode channelChatMessage event")
  func testChannelChatMessageEvent() async throws {
    let message = try await harness.testEvent(
      .channelChatMessage(broadcasterID: "111", userID: "222"),
      with: MockedMessages.channelChatMessage,
      requiringCondition: ["broadcaster_user_id": "111", "user_id": "222"])

    let received = try #require(message)
    #expect(received.message.text == "Hi chat [GIF]")
    #expect(received.messageType == .text)
    let fragments = received.message.fragments
    try #require(fragments.count == 2)
    #expect(fragments[0].text == "Hi chat ")
    guard case .text = fragments[0].type else {
      Issue.record("Expected text fragment, got \(fragments[0].type)")
      return
    }

    #expect(fragments[1].text == "[GIF]")
    guard case .gif(let gif) = fragments[1].type else {
      Issue.record("Expected GIF fragment, got \(fragments[1].type)")
      return
    }

    #expect(gif.gifID == "celebration-123")
    #expect(gif.url == "https://example.com/celebration.gif")
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

    #expect(notice.subscriptionTier == .tier1)
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

    #expect(notice.subscriptionTier == .tier1)
    #expect(notice.isPrime == false)
    #expect(notice.durationMonths == 1)
    #expect(notice.cumulativeMonths == 10)
    #expect(notice.streakMonths == nil)
    #expect(notice.gift == nil)
  }

  @Test("Should preserve unknown chat notification types")
  func unknownNoticeType() async throws {
    let fixture = MockedMessages.channelChatNotification.replacingOccurrences(
      of: "\"notice_type\": \"resub\"", with: "\"notice_type\": \"future_notice\"")
    let message = try await harness.testEvent(
      .channelChatNotification(broadcasterID: "111", userID: "222"),
      with: fixture,
      requiringCondition: ["broadcaster_user_id": "111", "user_id": "222"])

    let received = try #require(message)
    guard case .unknown(let type) = received.noticeType else {
      Issue.record("Expected unknown notice, got \(received.noticeType)")
      return
    }

    #expect(type == "future_notice")
  }

  @Test("Should preserve Shared Chat Modiversary details in managed chat")
  func sharedChatModiversary() async throws {
    let fixture = MockedMessages.channelChatNotificationSharedChat.replacingOccurrences(
      of: #""notice_type": "shared_chat_resub""#,
      with: """
        "notice_type": "shared_chat_modiversary",
        "shared_chat_modiversary": {"months":12},
        "is_source_only": true
        """)
    let event = try #require(
      try await harness.testEvent(
        .channelChatNotification(broadcasterID: "111", userID: "222"),
        with: fixture,
        requiringCondition: ["broadcaster_user_id": "111", "user_id": "222"]))
    guard case .sharedChatModiversary(let notice) = event.noticeType else {
      Issue.record("Expected a Shared Chat Modiversary notice")
      return
    }
    #expect(notice.months == 12)
    let normalized = ChatNotification(eventSub: event)
    #expect(normalized.kind == "shared_chat_modiversary")
    #expect(normalized.isSourceOnly == true)
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

  @Test("Should decode mention and GIF fragments in a held message")
  func heldMessageWithMentionAndGIF() throws {
    let data = Data(
      """
      {"text":"@viewer GIF","fragments":[
        {"type":"mention","text":"@viewer"},
        {"type":"gif","text":"GIF"}
      ]}
      """.utf8)
    let message = try TwitchClient.makeDecoder().decode(AutoModMessage.self, from: data)
    #expect(message.fragments.map(\.type) == [.mention, .gif])
  }

  @Test("Should decode the documented chat notice payloads")
  func documentedChatNoticePayloads() throws {
    let decoder = TwitchClient.makeDecoder()
    let resub = try decoder.decode(
      ChannelChatNotificationEvent.ResubNotice.self,
      from: Data(
        #"{"cumulative_months":2,"duration_months":1,"sub_tier":"1000","is_prime":null}"#.utf8))
    #expect(resub.isPrime == nil)

    let upgrade = try decoder.decode(
      ChannelChatNotificationEvent.GiftPaidUpgradeNotice.self,
      from: Data(
        #"{"gifter_is_anonymous":false,"gifter_user_id":"456","gifter_user_name":"Viewer"}"#.utf8))
    let gifter = try #require(upgrade.gifter)
    #expect(gifter.userID == "456")
    #expect(gifter.userLogin == nil)

    let donation = try decoder.decode(
      ChannelChatNotificationEvent.CharityDonationNotice.self,
      from: Data(
        #"{"charity_name":"Charity","amount":{"value":100,"decimal_place":2,"currency":"USD"}}"#
          .utf8))
    #expect(donation.amount.decimalPlaces == 2)
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
