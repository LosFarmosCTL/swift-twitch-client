import Foundation
import Testing

@testable import Twitch

extension ManagedChatTests {
  @Test(arguments: [false, true])
  func ircNormalizesActionAndEmoteOccurrences(isAction: Bool) async throws {
    let client = client()
    let events = await client.messageStream()
    let pending = Task { try await client.join(to: channel) }
    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    await acknowledge(socket)
    try await pending.value

    let text = "👩🏽‍💻 e\u{0301} Kappa PogChamp Kappa"
    let wireText = isAction ? "\u{1}ACTION \(text)\u{1}" : text
    await socket.simulateIncoming(
      .string(
        "@badge-info=;badges=;display-name=Chatter;emotes=25:8-12,23-27/88:14-21;"
          + "id=emotes;room-id=123;user-id=chatter "
          + ":chatter!chatter@chatter.tmi.twitch.tv PRIVMSG #swift :\(wireText)"
      ))

    let message = try #require(await nextMessage(in: events))
    #expect(message.text == text)
    #expect(message.isAction == isAction)
    #expect(message.emotes.map(\.id) == ["25", "88", "25"])
    #expect(message.emotes.map(\.name) == ["Kappa", "PogChamp", "Kappa"])
    #expect(message.emotes.map(\.range.unicodeScalarOffsets) == [8..<13, 14..<22, 23..<28])
    #expect(message.emotes.map { $0.range.text(in: message.text) } == message.emotes.map(\.name))
    await client.shutdownChat()
  }

  @Test
  func lateIRCMessageFromPreviousLoginIsIgnoredAfterRejoin() async throws {
    let client = client()
    let original = Task { try await client.join(to: channel) }
    let oldSocket = await session.waitForTask(at: 0)
    await handshake(oldSocket)
    await acknowledge(oldSocket)
    try await original.value
    await client.part(from: channel)

    let renamed = ChatChannel(id: channel.id, login: "swift_new")
    let rejoin = Task { try await client.join(to: renamed) }
    let socket = await session.waitForTask(at: 1)
    await handshake(socket)
    await socket.waitForSent("JOIN #swift_new")
    await socket.simulateIncoming(.string("@room-id=123 :tmi.twitch.tv ROOMSTATE #swift_new"))
    try await rejoin.value
    let events = await client.messageStream()

    let prefix = "@display-name=Chatter;room-id=123;user-id=42 :chat!chat@chat.tmi.twitch.tv"
    await socket.simulateIncoming(
      .string("\(prefix) PRIVMSG #swift :Late\r\n\(prefix) PRIVMSG #swift_new :Current"))

    let message = try #require(await nextMessage(in: events))
    #expect(message.text == "Current")
    let oldAlias = await client.withChat { $0.knownChannels[.login("swift")] }
    #expect(oldAlias == nil)
    await client.shutdownChat()
  }

  @Test
  func activeIRCChannelIgnoresMismatchedRoomIDAndSurvivesAliasCacheOverwrite() async throws {
    let client = client()
    await stubSending()
    let events = await client.messageStream()
    let pending = Task { try await client.join(to: channel) }
    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    await acknowledge(socket)
    try await pending.value

    // Sending to a renamed ChatChannel updates the alias cache without breaking active reads.
    _ = try await client.sendMessage(
      "hi", in: ChatChannel(id: channel.id, login: "swift_renamed"))

    await socket.simulateIncoming(
      .string(
        "@display-name=Chatter;room-id=999;user-id=42 :chat!chat@chat.tmi.twitch.tv PRIVMSG #swift :WrongRoom\r\n"
          + "@display-name=Chatter;room-id=123;user-id=42 :chat!chat@chat.tmi.twitch.tv PRIVMSG #swift :RightRoom"
      ))

    let message = try #require(await nextMessage(in: events))
    #expect(message.text == "RightRoom")
    await client.shutdownChat()
  }

  @Test
  func partAndRejoinOfFailedIRCChannelRetriesAndReachesReady() async throws {
    let client = client()
    let other = ChatChannel(id: "456", login: "other")
    let firstJoin = Task { try await client.join(to: other) }
    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    await socket.waitForSent("JOIN #other")
    await socket.simulateIncoming(.string("@room-id=456 :tmi.twitch.tv ROOMSTATE #other"))
    try await firstJoin.value

    let failedJoin = Task { try await client.join(to: channel) }
    await socket.waitForSent("JOIN #swift")
    await socket.simulateIncoming(
      .string("@msg-id=msg_room_not_found :tmi.twitch.tv NOTICE #swift :Unavailable"))
    await #expect(throws: ChatError.self) { try await failedJoin.value }

    try await client.partAndRejoinForTesting(channel)
    let retryJoin = Task { try await client.join(to: channel) }
    await socket.waitForSent("JOIN #swift", count: 2)
    await socket.simulateIncoming(.string("@room-id=123 :tmi.twitch.tv ROOMSTATE #swift"))
    try await retryJoin.value
    #expect(await client.chatState.channels[channel.id]?.status == .ready)
    await client.shutdownChat()
  }

  @Test
  func ircMetadataPreservesMissingValuesAndSettingsUpdatesArePartial() async throws {
    let client = client()
    let events = await client.messageStream()
    let pending = Task { try await client.join(to: channel) }
    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    await acknowledge(socket)
    try await pending.value
    let prefix = "@badge-info=;badges=;color=;display-name=Chatter;emotes=;id="
    let suffix =
      ";room-id=123;tmi-sent-ts=1700000000000;user-id=chatter "
      + ":chatter!chatter@chatter.tmi.twitch.tv PRIVMSG #swift :hello"
    await socket.simulateIncoming(.string(prefix + "one" + suffix))
    let missing = try #require(await nextMessage(in: events))
    #expect(missing.text == "hello")
    #expect(missing.isAction == false)
    #expect(missing.emotes.isEmpty)
    #expect(missing.isFirstMessage == nil)
    #expect(missing.isReturningChatter == nil)
    #expect(missing.contentFilterFlags == nil)
    await socket.simulateIncoming(
      .string(prefix + "two;flags=;first-msg=0;returning-chatter=1" + suffix))
    let present = try #require(await nextMessage(in: events))
    #expect(present.isFirstMessage == false)
    #expect(present.isReturningChatter == true)
    #expect(present.contentFilterFlags == nil)
    #expect(present.isIntroduction == nil)
    await socket.simulateIncoming(
      .string("@room-id=123;slow=10 :tmi.twitch.tv ROOMSTATE #swift"))
    let changed = try #require(
      await client.chatStateUpdates().first {
        $0.channels[channel.id]?.settings.slowMode == .seconds(10)
      })
    #expect(changed.channels[channel.id]?.settings.emoteOnly == false)
    #expect(changed.channels[channel.id]?.settings.followersOnly == nil)
    for (tags, suffix) in [
      ("", ""), (";system-msg=", " :"),
    ] {
      await socket.simulateIncoming(
        .string(
          "@msg-id=announcement;id=presence;room-id=123\(tags) :tmi.twitch.tv USERNOTICE #swift\(suffix)"
        ))
      let notice = try #require(await nextNotification(in: events)).notification
      #expect(notice.author == nil)
      #expect(notice.text == nil)
      #expect(notice.systemMessage == nil)
    }
    await client.shutdownChat()
  }

  @Test
  func parsedIRCFeedsRawAndNormalizedObserversIncludingUnknownSharedNotices() async throws {
    let client = client()
    let events = await client.messageStream()
    let raw = await client.ircMessageStream()
    let pending = Task { try await client.join(to: channel) }
    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    await acknowledge(socket)
    try await pending.value

    await socket.simulateIncoming(
      .string(
        "@msg-id=sharedchatnotice;source-msg-id=future_type;id=copy;room-id=123;"
          + "source-id=original;source-room-id=456;tmi-sent-ts=1700000000000 "
          + ":tmi.twitch.tv USERNOTICE #swift"
          + "\r\n@room-id=123;msg-id=future_Notice_v2__Beta;tmi-sent-ts=1700000000001 "
          + ":tmi.twitch.tv NOTICE #swift :Future notice"
      ))

    let shared = try #require(await nextNotification(in: events))
    #expect(shared.notification.kind == "shared_chat_future_type")
    #expect(shared.notification.sourceMessageID == "original")
    #expect(shared.notification.sourceChannelID == "456")
    #expect(shared.event.timestamp == Date(timeIntervalSince1970: 1_700_000_000))
    let notice = try #require(
      await events.first {
        if case .notice = $0.payload { true } else { false }
      })
    if case .notice(let code, let text) = notice.payload {
      #expect(code == "future_Notice_v2__Beta")
      #expect(text == "Future notice")
    }
    #expect(notice.timestamp == Date(timeIntervalSince1970: 1_700_000_000.001))

    try await verifyRawSharedNotices(in: raw)
    try await verifyKnownSharedNotice(on: socket, events: events)
    await client.shutdownChat()
  }

  private func verifyRawSharedNotices(in raw: AsyncStream<IRCMessage>) async throws {
    let rawShared = try #require(
      await raw.first {
        if case .userNotice = $0.message { true } else { false }
      })
    #expect(rawShared.role == .read)
    if case .userNotice(let value) = rawShared.message {
      guard case .sharedChatNotice(sourceNotice: nil) = value.kind else {
        Issue.record("Expected the original Shared Chat wrapper")
        return
      }
      #expect(value.sourceKind == "future_type")
    }
    let rawNotice = try #require(
      await raw.first {
        if case .notice = $0.message { true } else { false }
      })
    if case .notice(let value) = rawNotice.message {
      guard case .unknownLocal(_, _, let code) = value.kind else {
        Issue.record("Expected the parser's unknown NOTICE fallback")
        return
      }
      #expect(code == "future_Notice_v2__Beta")
    }
  }

  private func verifyKnownSharedNotice(
    on socket: MockWebSocketTask, events: AsyncStream<ChatEvent>
  ) async throws {
    await socket.simulateIncoming(
      .string(
        "@badge-info=;badges=;color=;display-name=Chatter;emotes=;id=shared;login=chatter;"
          + "msg-id=sharedchatnotice;source-msg-id=announcement;msg-param-color=PRIMARY;"
          + "room-id=123;source-room-id=456;source-id=original;system-msg=Announcement;"
          + "tmi-sent-ts=1700000000000;user-id=chatter "
          + ":tmi.twitch.tv USERNOTICE #swift :Shared announcement"
      ))
    let knownShared = try #require(await nextNotification(in: events)).notification
    #expect(knownShared.kind == "shared_chat_announcement")
    #expect(knownShared.sourceChannelID == "456")
    #expect(knownShared.sourceMessageID == "original")
    if case .ircSharedChat(let value) = knownShared.details {
      guard case .sharedChatNotice(sourceNotice: .announcement) = value.kind else {
        Issue.record("Expected the fork's typed Shared Chat announcement")
        return
      }
    } else {
      Issue.record("Expected Shared Chat IRC details")
    }
  }

  private func nextMessage(in events: AsyncStream<ChatEvent>) async -> ChatMessage? {
    for await event in events {
      if case .message(let message) = event.payload { return message }
    }
    return nil
  }

  @Test
  func targetedClearSeparatesModerationAndComputesTimeoutExpiryFromReceiptTime()
    async throws
  {
    let client = client()
    var events = await client.messageStream().makeAsyncIterator()
    let pending = Task { try await client.join(to: channel) }
    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    await acknowledge(socket)
    try await pending.value
    await socket.simulateIncoming(
      .string(
        "@ban-duration=60;room-id=123;target-user-id=\(first.userID!) :tmi.twitch.tv CLEARCHAT #swift :first"
      ))
    var clearing = false
    var expectedUntil: Date?
    while let event = await events.next() {
      switch event.payload {
      case .messagesCleared(let user):
        #expect(event.timestamp == nil)
        #expect(user?.id == first.userID)
        clearing = true
      case .moderation(let value):
        if case .timeout(let user, let until, let duration, _) = value.action {
          #expect(event.timestamp == nil)
          #expect(user.id == first.userID)
          #expect(until == event.receivedAt.addingTimeInterval(60))
          #expect(duration == .seconds(60))
          expectedUntil = until
        }
      default: break
      }
      if clearing && expectedUntil != nil { break }
    }
    let until = try #require(expectedUntil)
    #expect(clearing)
    #expect(await client.sendEligibility(in: channel.id) == .timedOut(until: until))
    await client.shutdownChat()
  }

  private func nextNotification(in events: AsyncStream<ChatEvent>) async
    -> (event: ChatEvent, notification: ChatNotification)?
  {
    for await event in events {
      if case .notification(let notice) = event.payload { return (event, notice) }
    }
    return nil
  }
}
