import Foundation
import Testing

@testable import Twitch

extension ManagedChatTests {
  @Test
  func observersAreLazyAndHelixSendingDoesNotStartReaderOrPaceRawRequests() async throws {
    let client = client()
    let states = await client.chatStateUpdates()
    let events = await client.messageStream()

    #expect(await session.taskCount() == 0)
    #expect(await session.requestCount() == 0)

    let observer = Task { for await _ in events {} }
    observer.cancel()
    await observer.value

    await stubSending()
    #expect(
      try await client.sendMessage("hello", to: channel)
        == .accepted(messageID: "message"))

    let refusal = await #expect(throws: ChatSendError.self) {
      try await client.sendMessage("too soon", to: channel)
    }
    #expect({ if case .refused(.channelCooldown) = refusal { true } else { false } }())
    #expect(await session.requestCount() == 1)

    _ = try await client.helix(for: .sendChatMessage(in: channel.id, message: "raw one"))
    _ = try await client.helix(for: .sendChatMessage(in: channel.id, message: "raw two"))

    #expect(await session.requestCount() == 3)
    #expect(await session.taskCount() == 0)
    #expect(await client.chatState.channels.isEmpty)
    _ = states
    await client.shutdownChat()
  }

  @Test
  func inFlightSendKeepsItsCredentialsAndCannotReplaceTheNewAccountsOutcome() async throws {
    let client = client()
    let beforeResponse = AsyncTestGate()
    let originalAuthorization = "Bearer \(first.accessToken)"
    await stubSending()
    await session.onRequest { request in
      if request.value(forHTTPHeaderField: "Authorization") == originalAuthorization {
        await beforeResponse.pause()
      }
    }

    let original = Task { try await client.sendMessage("old account", to: channel) }
    await beforeResponse.waitUntilEntered()
    await client.switchCredentials(to: second)

    await session.stub(
      url: URL(string: "https://api.twitch.tv/helix/chat/messages")!, method: "POST",
      body: Data(#"{"data":[{"message_id":"new-message","is_sent":true,"drop_reason":null}]}"#.utf8)
    )
    try await client.sendMessage("new account", to: channel)

    await beforeResponse.release()
    #expect(try await original.value == .accepted(messageID: "message"))
    #expect(
      await client.chatState.lastSendOutcomes[channel.id] == .accepted(messageID: "new-message"))
    let authorization = await session.requests().map {
      $0.value(forHTTPHeaderField: "Authorization")
    }
    #expect(authorization == [originalAuthorization, "Bearer \(second.accessToken)"])
    await client.shutdownChat()
  }

  @Test
  func privilegedSendsConsumeOrdinaryAccountEligibilityAndRefreshCannotEraseHistory()
    async throws
  {
    let client = client()
    await stubSending()
    let own = ChatChannel(id: first.userID!, login: "first")

    let anotherClient = self.client()
    _ = await anotherClient.sendEligibility(in: channel.id)
    let sharedUpdates = await anotherClient.chatStateUpdates()

    for index in 0..<50 {
      try await client.sendMessage("\(index)", to: own)
    }

    let sharedLimit = await sharedUpdates.first { state in
      if case .accountWindow = state.sendEligibility[channel.id] { return true }
      return false
    }
    #expect(sharedLimit != nil)

    let refusal = await #expect(throws: ChatSendError.self) {
      try await client.sendMessage(
        "ordinary", to: channel, waitingForChannelCooldown: .seconds(30))
    }
    #expect({ if case .refused(.accountWindow) = refusal { true } else { false } }())
    #expect(await session.requestCount() == 50)

    await client.switchCredentials(to: first)
    let refreshed = await client.sendEligibility(in: channel.id)
    #expect({ if case .accountWindow = refreshed { true } else { false } }())

    for index in 50..<100 {
      try await client.sendMessage("\(index)", to: own)
    }

    await #expect(throws: ChatSendError.self) {
      try await client.sendMessage("101", to: own)
    }
    #expect(await session.requestCount() == 100)

    await #expect(throws: ChatSendError.self) {
      try await anotherClient.sendMessage("shared budget", to: own)
    }
    #expect(await session.requestCount() == 100)
    await anotherClient.shutdownChat()

    await client.switchCredentials(to: second)
    #expect(await client.sendEligibility(in: channel.id) == .eligible)

    await client.switchCredentials(to: first)
    let restored = await client.sendEligibility(in: own.id)
    #expect({ if case .accountWindow = restored { true } else { false } }())
    await client.shutdownChat()
  }

  @Test
  func ircSendingStartsOnlyWriterAndCancellationDoesNotCancelAnotherSend() async throws {
    let client = client(writer: .irc)
    let own = ChatChannel(id: first.userID!, login: "first")
    let cancelled = Task { try await client.sendMessage("cancelled", to: own) }
    let socket = await session.waitForTask(at: 0)
    let remaining = Task {
      try await client.sendMessage("sent", to: own, clientNonce: "nonce")
    }

    cancelled.cancel()
    await #expect(throws: CancellationError.self) { try await cancelled.value }
    #expect(await socket.didCancel == false)

    await handshake(socket, authenticated: first)
    #expect(try await remaining.value == .written(clientNonce: "nonce"))
    #expect(await socket.sentCount(prefix: "JOIN") == 0)
    #expect(await session.taskCount() == 1)
    #expect(await client.chatState.channels.isEmpty)
    #expect(await client.chatState.reader == .idle)

    await socket.simulateIncoming(
      .string("@msg-id=msg_rejected :tmi.twitch.tv NOTICE #first :Rejected"))
    _ = try #require(
      await client.chatStateUpdates().first {
        $0.lastSendOutcomes[own.id]
          == .rejected(code: "msg_rejected", message: "Rejected")
      })
    await client.shutdownChat()
  }

  @Test
  func unjoinedWriterEvidenceUpdatesEligibilityAndUsesTheNoticeTarget() async throws {
    let client = TwitchClient(
      credentials: first,
      chat: .init(writer: .irc, sending: .init(ordinaryChannelInterval: .seconds(30))),
      network: session)
    let events = await client.messageStream()
    let firstSend = Task { try await client.sendMessage("ordinary", to: channel) }
    let writer = await session.waitForTask(at: 0)
    await handshake(writer, authenticated: first)
    _ = try await firstSend.value
    let initial = await client.sendEligibility(in: channel.id)
    #expect({ if case .channelCooldown = initial { true } else { false } }())

    await writer.simulateIncoming(
      .string(
        "@badge-info=;badges=vip/1;color=;display-name=first;emote-sets= "
          + ":tmi.twitch.tv USERSTATE #swift"))
    _ = try #require(
      await client.chatStateUpdates().first { $0.sendEligibility[channel.id] == .eligible })

    await writer.simulateIncoming(
      .string("@msg-id=msg_banned;target-user-id=someone-else :tmi.twitch.tv NOTICE #swift :Other"))
    _ = try #require(
      await events.first { if case .notice = $0.payload { true } else { false } })
    #expect(await client.sendEligibility(in: channel.id) == .eligible)
    #expect(await client.chatState.lastSendOutcomes[channel.id] == .written(clientNonce: nil))

    try await client.sendMessage("as vip", to: channel)
    let target = try #require(first.userID)
    await writer.simulateIncoming(
      .string("@msg-id=msg_banned;target-user-id=\(target) :tmi.twitch.tv NOTICE #swift :Banned"))
    _ = try #require(
      await client.chatStateUpdates().first { $0.sendEligibility[channel.id] == .banned })
    let outcome = try await client.sendMessage("let Twitch decide", to: channel)
    #expect(outcome == .written(clientNonce: nil))
    #expect(await writer.sentCount(prefix: "PRIVMSG #swift") == 3)
    #expect(await client.chatState.channels.isEmpty)
    await client.shutdownChat()
  }

  @Test
  func serverRejectionsStayTypedWithoutRetryFallbackOrInventedChatExpiry() async throws {
    let client = client()
    let own = ChatChannel(id: first.userID!, login: "first")
    let url = URL(string: "https://api.twitch.tv/helix/chat/messages")!

    await session.stub(
      url: url, method: "POST", status: 429,
      headers: ["Ratelimit-Limit": "15000", "Ratelimit-Remaining": "14999"],
      body: Data(
        """
        {"error":"Too Many Requests","status":429,
         "message":"Your message was not sent because you are sending messages too quickly."}
        """
        .utf8))

    let rateLimit = await #expect(throws: HelixError.self) {
      try await client.sendMessage("first", to: own)
    }
    #expect({ if case .rateLimited = rateLimit { true } else { false } }())
    #expect(await client.chatState.lastSendOutcomes[own.id] == .rateLimited)

    await session.stub(
      url: url, method: "POST",
      body: Data(
        #"{"data":[{"message_id":"","is_sent":false,"drop_reason":{"code":"msg_rejected","message":"Rejected"}}]}"#
          .utf8))

    await #expect(
      throws: ChatSendError.rejected(code: "msg_rejected", message: "Rejected")
    ) {
      try await client.sendMessage("second", to: own)
    }
    #expect(
      await client.chatState.lastSendOutcomes[own.id]
        == .rejected(code: "msg_rejected", message: "Rejected"))

    // Local evidence only, not a guarantee of server eligibility.
    #expect(await client.sendEligibility(in: own.id) == .eligible)
    #expect(await session.requestCount() == 2)
    #expect(await session.taskCount() == 0)
    await client.shutdownChat()
  }
}
