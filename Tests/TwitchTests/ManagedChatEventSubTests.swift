import Foundation
import Testing

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@Suite(.timeLimit(.minutes(1)))
struct ManagedChatEventSubTests {
  let session = MockNetworkSession()
  let channel = ChatChannel(id: "123", login: "swift")
  private let other = ChatChannel(id: "456", login: "other")
  private let topics = [
    "channel.chat.message", "channel.chat.notification", "channel.chat.message_delete",
    "channel.chat.clear", "channel.chat.clear_user_messages",
    "channel.chat_settings.update",
    "channel.moderate",
  ]

  @Test
  func requiredRevocationPartsWholeManagedChannelButNotRawOwnerOrOtherChannel()
    async throws
  {
    let client = await client()
    let raw = try await client.eventStream(
      for: .channelChatMessage(broadcasterID: channel.id, userID: "999"))
    let events = await client.messageStream()
    try await client.join(to: channel)
    try await client.join(to: other)
    #expect(await postCount() == 12)
    let message = try notification(
      MockedMessages.channelChatMessage, type: "channel.chat.message")
    await session.simulateIncoming(.string(message))
    let normalized = try #require(
      await events.first { if case .message = $0.payload { true } else { false } })
    if case .message(let message) = normalized.payload {
      #expect(message.isFirstMessage == nil)
      #expect(message.isReturningChatter == nil)
      #expect(message.contentFilterFlags == nil)
    }
    var rawIterator = raw.makeAsyncIterator()
    let original = try #require(try await rawIterator.next())
    #expect(normalized.timestamp == original.sentAt)

    await session.simulateIncoming(
      .string(
        MockedMessages.customized(
          MockedMessages.mockRevocationMessage.replacingOccurrences(
            of: "authorization_revoked", with: "chat_user_banned"),
          subscriptionID: "channel.chat.clear-123")))
    let state = try #require(
      await client.chatStateUpdates().first { $0.channels[self.channel.id] == nil })
    #expect(state.channels[other.id]?.status == .ready)
    #expect(state.lastDeparture?.reason == .subscriptionRevoked(.chatUserBanned))
    let context = await client.eventSubClient
    while await context.subscriptionObserverCount != 7 { await Task.yield() }
    #expect(await session.lastTask()?.didCancel == false)
    #expect(await postCount() == 12)
    await session.simulateIncoming(
      .string(
        try notification(
          MockedMessages.channelChatMessage,
          type: "channel.chat.message", envelopeID: "after-part")))
    _ = try #require(try await rawIterator.next())
    await client.shutdownChat()
    await client.resetEventSub()
  }

  @Test
  func requiredRevocationEndsChatWhileAnotherTopicIsStillSettingUp() async throws {
    let client = await client()
    let rawMessages = try await client.eventStream(
      for: .channelChatMessage(broadcasterID: channel.id, userID: "999"))
    let rawClears = try await client.eventStream(
      for: .channelChatClear(broadcasterID: channel.id, userID: "999"))
    let events = await client.messageStream()
    let gate = AsyncTestGate()
    await session.onRequest { request in
      if request.httpMethod == "POST", let body = request.httpBody,
        let description = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
        description["type"] as? String == "channel.chat_settings.update"
      {
        await gate.pause()
      }
    }

    let pending = Task { try await client.join(to: channel) }
    await gate.waitUntilEntered()
    let eventSub = await client.eventSubClient
    while await eventSub.subscriptionObserverCount < 8 { await Task.yield() }

    await session.simulateIncoming(
      .string(try notification(MockedMessages.channelChatMessage, type: "channel.chat.message")))
    await session.simulateIncoming(
      .string(
        MockedMessages.customized(
          MockedMessages.mockRevocationMessage, subscriptionID: "channel.chat.clear-123")))

    var iterator = events.makeAsyncIterator()
    let message = await iterator.next()
    let departure = await iterator.next()
    await gate.release()

    if case .message = message?.payload {} else { Issue.record("The earlier message was lost") }
    if case .membershipEnded(.subscriptionRevoked) = departure?.payload {
    } else {
      Issue.record("The managed channel did not report the revocation")
    }
    await #expect(throws: ChatError.setupFailed("Required chat subscription ended")) {
      try await pending.value
    }
    while await eventSub.subscriptionObserverCount != 1 { await Task.yield() }
    #expect(await client.chatState.channels.isEmpty)

    withExtendedLifetime((rawMessages, rawClears)) {}
    await client.shutdownChat()
    await client.resetEventSub()
  }

  @Test
  func optionalRevocationKeepsChatAndVIPAndDeletionDedupSurvivesTransition() async throws {
    let client = await client(moderation: true)
    try await client.join(to: channel)
    let raw = try await client.eventStream(
      for: .channelChatMessageDelete(broadcasterID: channel.id, userID: "999"))
    let events = await client.messageStream()
    await client.setChatPrivilege(
      ChatPrivilege(isModerator: true, isVIP: true), in: channel.id)
    _ = try #require(
      await client.chatStateUpdates().first {
        $0.channels[self.channel.id]?.moderation == .ready
      })
    #expect(await postCount() == 7)

    await session.simulateIncoming(
      .string(try deletion(messageID: "deleted", envelopeID: "basic")))
    var rawIterator = raw.makeAsyncIterator()
    _ = try #require(try await rawIterator.next())
    await session.simulateIncoming(.string(try moderationDeletion(messageID: "deleted")))
    let deletedMessage = try #require(await nextDeletion(in: events))
    #expect(deletedMessage.text == "original text")
    #expect(deletedMessage.moderator?.id == "moderator")

    let later = await client.messageStream()
    await session.simulateIncoming(
      .string(
        MockedMessages.customized(
          MockedMessages.mockRevocationMessage.replacingOccurrences(
            of: "authorization_revoked", with: "new_authorization_reason"),
          subscriptionID: "channel.moderate-123")))
    let state = try #require(
      await client.chatStateUpdates().first {
        if case .failed = $0.channels[self.channel.id]?.moderation { true } else { false }
      })
    #expect(state.channels[channel.id]?.status == .ready)
    #expect(state.channels[channel.id]?.privilege.isVIP == true)
    #expect(state.channels[channel.id]?.privilege.isModerator == true)
    #expect(
      state.channels[channel.id]?.moderationRevocation
        == .unknown("new_authorization_reason"))
    await session.simulateIncoming(
      .string(try deletion(messageID: "deleted", envelopeID: "duplicate")))
    await session.simulateIncoming(
      .string(try deletion(messageID: "next", envelopeID: "next")))
    let next = try #require(await nextDeletion(in: later))
    #expect(next.messageID == "next")
    #expect(next.text == nil)
    #expect(await postCount() == 7)
    await client.shutdownChat()
    await client.resetEventSub()
  }

  @Test
  func releasingRootCancelsPendingManagedSetupAndFinishesObservers() async throws {
    var instance: TwitchClient? = await client(welcome: false)
    weak let observed = instance
    let events = await instance!.messageStream()
    try await instance!.requestJoin(to: channel)
    let socket = await session.waitForTask(at: 0)
    instance = nil
    await socket.waitForCancellation()
    #expect(observed == nil)
    var iterator = events.makeAsyncIterator()
    #expect(await iterator.next() == nil)
  }

  @Test
  func directRoleEvidenceOutranksLatePrefillAndSurvivesPartRejoin() async throws {
    let gate = AsyncTestGate()
    await stubModerationPrefill()
    await session.onRequest { request in
      if request.url?.path == "/helix/moderation/channels" { await gate.pause() }
    }
    let client = await client(moderation: true, prefill: true)
    try await client.join(to: channel)
    await gate.waitUntilEntered()
    await session.simulateIncoming(
      .string(
        try notification(MockedMessages.channelChatMessage, type: "channel.chat.message") {
          var event = $0
          event["chatter_user_id"] = "999"
          event["source_broadcaster_user_id"] = NSNull()
          event["badges"] = [["set_id": "vip", "id": "1", "info": ""]]
          return event
        }))
    _ = try #require(
      await client.chatStateUpdates().first {
        $0.channels[self.channel.id]?.privilege.isVIP == true
      })
    await gate.release()
    await client.moderationPrefillTask?.value
    #expect(Set(await client.chatState.sendEligibility.keys) == [channel.id])
    await client.part(channelID: channel.id)
    await session.simulateIncoming(.string(MockedMessages.welcomeMessage), queue: true)
    try await client.join(to: channel)
    let state = await client.chatState
    #expect(state.channels[channel.id]?.privilege.isModerator == false)
    #expect(state.channels[channel.id]?.privilege.isVIP == true)
    #expect(
      {
        if case .unavailable = state.channels[channel.id]?.moderation {
          true
        } else {
          false
        }
      }())
    await client.shutdownChat()
    await client.resetEventSub()
  }

  @Test
  func channelSetupFailureDoesNotFailHealthyReaderOrCollapsePresentEmptyNotificationText()
    async throws
  {
    let client = await client()
    try await client.join(to: channel)
    let messages = await client.messageStream()
    await session.simulateIncoming(
      .string(
        try notification(
          MockedMessages.channelChatNotification, type: "channel.chat.notification"
        ) {
          var event = $0
          event["system_message"] = ""
          event["message"] = ["text": "", "fragments": []] as [String: Any]
          return event
        }))
    let event = try #require(
      await messages.first { if case .notification = $0.payload { true } else { false } })
    if case .notification(let notice) = event.payload {
      #expect(notice.text == "")
      #expect(notice.systemMessage == "")
    }
    await session.stub(
      url: URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions")!,
      method: "POST", status: 403,
      body: Data(
        #"{"error":"Forbidden","status":403,"message":"subscription missing proper authorization"}"#
          .utf8))
    await #expect(throws: HelixError.self) { try await client.join(to: other) }
    let state = await client.chatState
    #expect(state.reader == .ready)
    #expect(state.channels[channel.id]?.status == .ready)
    #expect(
      { if case .failed = state.channels[other.id]?.status { true } else { false } }())
    #expect(await session.lastTask()?.didCancel == false)
    await client.shutdownChat()
    await client.resetEventSub()
  }

}

extension ManagedChatEventSubTests {
  func client(
    moderation: Bool = false, welcome: Bool = true, prefill: Bool = false
  ) async
    -> TwitchClient
  {
    let credentials = TwitchCredentials(
      accessToken: "token", clientID: "app", userID: "999", userLogin: "sender",
      scopes: [
        "moderator:read:blocked_terms", "moderator:read:chat_settings",
        "moderator:read:unban_requests",
        "moderator:read:banned_users", "moderator:read:chat_messages",
        "moderator:read:moderators", "moderator:read:vips",
        "user:read:moderated_channels",
      ])
    let url = URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions")!
    await session.stub(url: url, method: "POST") { request in
      let body = try #require(request.httpBody)
      let description = try #require(
        JSONSerialization.jsonObject(with: body) as? [String: Any])
      let type = try #require(description["type"] as? String)
      let condition = try #require(description["condition"] as? [String: String])
      let id = type + "-" + (try #require(condition["broadcaster_user_id"]))
      return (
        Data(
          MockedMessages.customized(
            MockedMessages.mockEventSubSubscription, subscriptionID: id
          ).utf8),
        HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
      )
    }
    for id in [channel.id, other.id] {
      for topic in topics {
        await session.stub(
          url: url.appending(queryItems: [.init(name: "id", value: topic + "-" + id)]),
          method: "DELETE", status: 204)
      }
    }
    if welcome {
      await session.simulateIncoming(.string(MockedMessages.welcomeMessage), queue: true)
    }
    return TwitchClient(
      credentials: credentials,
      chat: .init(
        reader: .eventSub, moderationEnrichment: moderation,
        prefillModeratedChannels: prefill), network: session)
  }

  private func stubModerationPrefill() async {
    await session.stub(
      url: URL(
        string: "https://api.twitch.tv/helix/moderation/channels?first=100&user_id=999")!,
      body: Data(
        """
        {"data":[
          {"broadcaster_id":"123","broadcaster_login":"swift","broadcaster_name":"Swift"},
          {"broadcaster_id":"456","broadcaster_login":"other","broadcaster_name":"Other"}
        ],"pagination":{}}
        """
        .utf8))
  }

  private func nextDeletion(in events: AsyncStream<ChatEvent>) async
    -> ChatMessageDeletion?
  {
    for await event in events {
      if case .messageDeleted(let deletion) = event.payload { return deletion }
    }
    return nil
  }

  func postCount() async -> Int {
    await session.requests().filter { $0.httpMethod == "POST" }.count
  }

  func notification(
    _ fixture: String, type: String, envelopeID: String = UUID().uuidString,
    transform: ([String: Any]) -> [String: Any] = { $0 }
  ) throws -> String {
    var root =
      try #require(
        JSONSerialization.jsonObject(with: Data(fixture.utf8)) as? [String: Any])
    var metadata = try #require(root["metadata"] as? [String: Any])
    metadata["message_id"] = envelopeID
    root["metadata"] = metadata
    var payload = try #require(root["payload"] as? [String: Any])
    var subscription = try #require(payload["subscription"] as? [String: Any])
    subscription["id"] = type + "-123"
    subscription["type"] = type
    subscription["version"] = "1"
    payload["subscription"] = subscription
    payload["event"] = transform(try #require(payload["event"] as? [String: Any]))
    root["payload"] = payload
    return try #require(
      String(data: JSONSerialization.data(withJSONObject: root), encoding: .utf8))
  }

  private func deletion(messageID: String, envelopeID: String) throws -> String {
    try notification(
      MockedMessages.channelChatMessageDelete, type: "channel.chat.message_delete",
      envelopeID: envelopeID
    ) {
      var event = $0
      event["message_id"] = messageID
      return event
    }
  }

  private func moderationDeletion(messageID: String) throws -> String {
    try notification(MockedMessages.channelModerateTimeoutUser, type: "channel.moderate") {
      var event = $0
      event["moderator_user_id"] = "moderator"
      event["action"] = "delete"
      event["delete"] = [
        "user_id": "author", "user_login": "author", "user_name": "Author",
        "message_id": messageID, "message_body": "original text",
      ]
      return event
    }
  }
}
