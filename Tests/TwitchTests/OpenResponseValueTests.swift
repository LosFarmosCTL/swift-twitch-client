import Foundation
import Testing

@testable import Twitch

struct OpenResponseValueTests {
  @Test
  func stringClassificationsPreserveUnfamiliarValues() throws {
    try checkValues(ChannelChatMessageEvent.MessageType.self, known: .text)
    try checkValues(User.BroadcasterType.self, known: .partner)
    try checkValues(EventSubRevocation.Status.self, known: .authorizationRevoked)
    try checkValues(SubscriptionTier.self, known: .tier1)
    try checkValues(GuestStarGroupLayout.self, known: .horizontalLayout)
    try checkValues(HypeTrainType.self, known: .goldenKappa)
    try checkValues(VideoType.self, known: .archive)
    try checkValues(AutoModMessage.Fragment.FragmentType.self, known: .emote)
    try checkValues(
      ChannelPointsAutomaticRewardRedemptionAddEvent.Reward.RewardType.self,
      known: .sendHighlightedMessage)

    let decoder = JSONDecoder()
    let broadcaster = try decoder.decode(User.BroadcasterType.self, from: Data(#""""#.utf8))
    #expect(broadcaster == .none)
    #expect(broadcaster != .init(rawValue: "future_value"))

    let reasons: [(String, EventSubRevocation.Status)] = [
      ("chat_user_banned", .chatUserBanned), ("chat_user_timed_out", .chatUserTimedOut),
    ]
    for (reason, status) in reasons {
      let data = try JSONEncoder().encode(reason)
      #expect(try decoder.decode(EventSubRevocation.Status.self, from: data) == status)
    }
  }

  @Test
  func unfamiliarFragmentsKeepTheirTextWhileKnownFragmentsRequireTheirPayload() throws {
    let decoder = JSONDecoder()
    let data = Data(
      #"{"type":"future_fragment","text":"fallback text","future_fragment":{"new":true}}"#.utf8)
    let chat = try decoder.decode(ChannelChatMessageEvent.Message.Fragment.self, from: data)
    let bits = try decoder.decode(ChannelBitsUseEvent.Message.Fragment.self, from: data)
    let suspicious = try decoder.decode(
      ChannelSuspiciousUserMessageEvent.Message.Fragment.self, from: data)

    #expect(chat.text == "fallback text")
    #expect(bits.text == chat.text)
    #expect(suspicious.text == chat.text)
    guard case .unknown("future_fragment") = chat.type,
      case .unknown("future_fragment") = bits.type,
      case .unknown("future_fragment") = suspicious.type
    else {
      Issue.record("Expected preserved unfamiliar fragment discriminators")
      return
    }

    #expect(throws: DecodingError.self) {
      try decoder.decode(
        ChannelChatMessageEvent.Message.Fragment.self,
        from: Data(#"{"type":"emote","text":"broken"}"#.utf8))
    }
  }

  @Test
  func unfamiliarModerationActionsReachManagedChatWhileKnownActionsRequireTheirPayload() throws {
    let fixture = MockedMessages.channelModerateTimeoutUser
    let unfamiliar = try decodeModerationEvent(
      fixture.replacingOccurrences(of: #""action": "timeout""#, with: #""action": "future_action""#)
    )
    #expect(unfamiliar.broadcasterID == "423374343")
    guard
      case .eventSub(.unknown("future_action")) = ChatModeration.Action(eventSub: unfamiliar.action)
    else {
      Issue.record("Expected managed chat to forward the unfamiliar moderation action")
      return
    }

    let known = try decodeModerationEvent(fixture)
    guard case .timeout(let timeout) = known.action else {
      Issue.record("Expected typed timeout action")
      return
    }
    #expect(timeout.userID == "141981764")

    let malformed = fixture.replacingOccurrences(
      of: #""user_id": "141981764""#, with: #""user_id": null"#)
    #expect(throws: DecodingError.self) {
      try decodeModerationEvent(malformed)
    }
  }

  @Test
  func unfamiliarAutoModHoldReasonAndNullableEventFieldsDecodeCleanly() throws {
    let decoder = TwitchClient.makeDecoder()

    let unknownHold = try decoder.decode(
      AutoModMessageHoldEvent.self,
      from: Data(
        """
        {
          "broadcaster_user_id": "1",
          "broadcaster_user_login": "broadcaster",
          "broadcaster_user_name": "Broadcaster",
          "user_id": "2",
          "user_login": "viewer",
          "user_name": "Viewer",
          "message_id": "msg-1",
          "message": {"text": "hi", "fragments": []},
          "held_at": "2026-01-01T00:00:00Z",
          "reason": "future_reason"
        }
        """.utf8))
    guard case .unknown("future_reason") = unknownHold.reason else {
      Issue.record("Expected unknown AutoModHoldReason")
      return
    }

    let message = try decoder.decode(
      ChannelSubscriptionMessageEvent.Message.self,
      from: Data(#"{"text":"Thanks!","emotes":null}"#.utf8))
    #expect(message.text == "Thanks!")
    #expect(message.emotes.isEmpty)

    let canceledPrediction = try decoder.decode(
      ChannelPredictionEndEvent.self,
      from: Data(
        """
        {
          "id": "1",
          "broadcaster_user_id": "2",
          "broadcaster_user_login": "broadcaster",
          "broadcaster_user_name": "Broadcaster",
          "title": "Test",
          "winning_outcome_id": null,
          "outcomes": [],
          "status": "canceled",
          "started_at": "2026-01-01T00:00:00Z",
          "ended_at": "2026-01-01T00:05:00Z"
        }
        """.utf8))
    #expect(canceledPrediction.winningOutcomeID == nil)
    #expect(canceledPrediction.status == .cancelled)
  }

  private func checkValues<T: RawRepresentable & Decodable & Hashable>(
    _ type: T.Type, known: T
  ) throws where T.RawValue == String {
    let decoder = JSONDecoder()
    let unfamiliar = try decoder.decode(type, from: Data(#""future_value""#.utf8))
    #expect(unfamiliar.rawValue == "future_value")
    let constructed = try #require(T(rawValue: "future_value"))
    #expect(unfamiliar == constructed)
    #expect(Set([unfamiliar, constructed, known]).count == 2)
    let data = try JSONEncoder().encode(known.rawValue)
    #expect(try decoder.decode(type, from: data) == known)
    #expect(throws: DecodingError.self) {
      try decoder.decode(type, from: Data("42".utf8))
    }
  }

  private func decodeModerationEvent(_ fixture: String) throws -> ChannelModerateEvent {
    struct Envelope: Decodable {
      struct Payload: Decodable {
        let event: ChannelModerateEvent
      }

      let payload: Payload
    }

    return try TwitchClient.makeDecoder()
      .decode(Envelope.self, from: Data(fixture.utf8)).payload.event
  }
}
