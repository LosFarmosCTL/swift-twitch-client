import Foundation
import Testing
import TwitchIRC

@testable import Twitch

extension ManagedIRCTests {
  @Test
  func rawWritesUseOnlyTheWriterAndBypassManagedAdmission() async throws {
    let client = client()
    let pending = Task {
      try await client.sendIRC(.privateMessage(to: "swift", message: "raw one"))
    }
    let writer = await session.waitForTask(at: 0)
    await handshake(writer, authenticated: true)
    try await pending.value
    try await client.sendIRC(.privateMessage(to: "swift", message: "raw two"))

    #expect(await client.chatState.reader == .idle)
    #expect(await client.chatState.channels.isEmpty)
    #expect(await client.sendEligibility(in: channel.id) == .eligible)
    #expect(await writer.sentCount(prefix: "JOIN") == 0)

    try await client.sendMessage("managed", to: channel)
    await #expect(throws: ChatSendError.self) {
      try await client.sendMessage("blocked", to: channel)
    }
    try await client.sendIRC(.privateMessage(to: "swift", message: "raw three"))

    #expect(await writer.sentCount(prefix: "PRIVMSG #swift") == 4)
    await client.shutdownChat()
  }

  @Test
  func retiringTheCapturedSocketPreventsAdmissionBeforeDispatch() async throws {
    let connection = IRCConnection(credentials: credentials, network: session)
    let connect = Task { try await connection.connect() }
    let socket = await session.waitForTask(at: 0)
    await handshake(socket, authenticated: true)
    let messages = try await connect.value

    let gate = AsyncTestGate()
    let frame = try IRCWireMessage(.privateMessage(to: "swift", message: "never sent"))
    let sender = UUID().uuidString
    let limiter = ChatSendLimiter()
    let attempt = Task {
      try await connection.send(frame) { permit in
        await gate.pause()
        _ = try permit.commit {
          limiter.commit(
            account: sender, channel: channel.id, privileged: false, interval: .seconds(1),
            enforcesLimits: true)
        }
      }
    }

    await gate.waitUntilEntered()
    await connection.disconnect()
    await gate.release()
    await #expect(throws: IRCDispatchRefused.self) { try await attempt.value }
    #expect(await socket.sentCount(prefix: "PRIVMSG") == 0)
    #expect(
      ChatSendLimiter.limit(
        limiter.snapshot(for: sender), channel: channel.id, privileged: false,
        interval: .seconds(1), now: .now) == nil)
    withExtendedLifetime(messages) {}
  }

  @Test
  func rawWritesNormalizeAndEscapeTagsWithoutWeakeningFramingSafety() async throws {
    let client = client()
    await #expect(throws: IRCError.self) {
      try await client.sendIRC(.join(to: "swift other"))
    }
    await #expect(throws: ChatSendError.invalidMessage) {
      try await client.sendMessage("hello\r\nJOIN #other", to: channel)
    }
    #expect(await session.taskCount() == 0)
    let pending = Task {
      try await client.sendIRC(.privateMessage(to: "#SWIFT", message: "first"))
    }
    let writer = await session.waitForTask(at: 0)
    await handshake(writer, authenticated: true)
    try await pending.value

    let text = "hello ; \\s : café 👋"
    try await client.sendIRC(
      .privateMessage(
        to: "###SWIFT", message: text, messageIDToReply: "parent;tag \\\r\n",
        clientNonce: "nonce;tag \\\r\n"))
    #expect(
      await writer.sentCount(
        prefix: "@reply-parent-msg-id=parent\\:tag\\s\\\\\\r\\n;"
          + "client-nonce=nonce\\:tag\\s\\\\\\r\\n PRIVMSG #swift :\(text)") == 1)

    for message: OutgoingMessage in [
      .privateMessage(to: "swift", message: "hello\r\nJOIN #other"),
      .privateMessage(to: "swift", message: "hello\0"),
      .privateMessage(to: "swift", message: "hello", clientNonce: "bad\0"),
      .join(to: "swift,other"), .part(from: "swift#"),
      .nick(name: "bad\nlogin"), .pass(pass: "bad token"),
    ] {
      await #expect(throws: IRCError.self) { try await client.sendIRC(message) }
    }
    #expect(await session.taskCount() == 1)
    #expect(await writer.didCancel == false)
    #expect(await writer.sentCount(prefix: "PRIVMSG") == 1)
    #expect(await writer.sentCount(prefix: "JOIN") == 0)

    try await client.sendMessage(
      text, to: channel, replyTo: "parent;tag", clientNonce: "nonce \\")
    #expect(
      await writer.sentCount(
        prefix:
          "@reply-parent-msg-id=parent\\:tag;client-nonce=nonce\\s\\\\ PRIVMSG #swift :\(text)"
      )
        == 1)
    await client.shutdownChat()
  }

}
