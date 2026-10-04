import Foundation
import Testing

@testable import Twitch

private let capabilities = ":tmi.twitch.tv CAP * ACK :twitch.tv/commands twitch.tv/tags"
private let welcome = ":tmi.twitch.tv 001 justinfan12345 :Welcome, GLHF!"

@Suite(.timeLimit(.minutes(1)))
struct IRCRecoveryTests {
  private let session = MockNetworkSession()

  private func handshake(_ socket: MockWebSocketTask) async {
    await socket.simulateIncoming(.string(capabilities + "\r\n" + welcome))
  }

  @Test(arguments: [false, true])
  func handshakeAcceptsReorderedMessages(grouped: Bool) async throws {
    let connection = IRCConnection(
      credentials: .init(
        oAuth: "token", clientID: "id", userID: "123", userLogin: "tester"),
      network: session)

    let pending = Task { try await connection.connect() }
    let socket = await session.waitForTask(at: 0)
    let lines = [
      "@badge-info=;badges=;color=;display-name=tester;emote-sets=0;"
        + "user-id=123;user-type= :tmi.twitch.tv GLOBALUSERSTATE",
      "PING :tmi.twitch.tv",
      ":tmi.twitch.tv CAP * ACK :twitch.tv/tags",
      ":tmi.twitch.tv 002 tester :Your host is tmi.twitch.tv",
      ":tmi.twitch.tv CAP * ACK :twitch.tv/commands",
      ":tester!tester@tester.tmi.twitch.tv JOIN #swift",
    ]

    let frames = if grouped { [lines.joined(separator: "\r\n")] } else { lines }

    for frame in frames {
      await socket.simulateIncoming(.string(frame))
    }

    var iterator = try await pending.value.makeAsyncIterator()
    let first = try #require(try await iterator.next())

    if case .globalUserState(let state) = first {
      #expect(state.userId == "123")
    } else {
      Issue.record("Handshake lost GLOBALUSERSTATE")
    }

    let second = try #require(try await iterator.next())

    if case .join(let join) = second {
      #expect(join.channel == "swift")
    } else {
      Issue.record("Handshake lost a coalesced message")
    }

    #expect(await socket.sentCount(prefix: "PONG :tmi.twitch.tv") == 1)

    await connection.disconnect()
  }

  @Test
  func handshakeTimeoutClosesSocket() async throws {
    let connection = IRCConnection(network: session, handshakeTimeout: .milliseconds(20))
    let pending = Task { try await connection.connect() }
    let socket = await session.waitForTask(at: 0)

    let error = await #expect(throws: IRCError.self) { try await pending.value }
    if case .handshakeTimedOut = error {
    } else {
      Issue.record("Expected timeout")
    }

    #expect(await socket.didCancel)
  }

  @Test
  func pendingMembershipIsReservedAndLateJoinIsParted() async throws {
    let pool = IRCConnectionPool(network: session)
    let pending = Task { try await pool.connect() }
    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    var messages = try await pending.value.makeAsyncIterator()

    try await pool.join(to: "other")
    try await pool.join(to: "#SWIFT")
    try await pool.join(to: "swift")
    await socket.waitForSent("JOIN #swift")

    #expect(await socket.sentCount(prefix: "JOIN #swift") == 1)

    try await pool.part(from: "#swift")
    await socket.waitForSent("PART #swift")

    await socket.simulateIncoming(
      .string(
        ":justinfan12345!justinfan12345@justinfan12345.tmi.twitch.tv JOIN #swift"))
    _ = try await messages.next()

    #expect(await socket.sentCount(prefix: "PART #swift") == 2)
    var statuses = await pool.channelStatusSnapshots().makeAsyncIterator()
    #expect(await statuses.next() == ["other": .joining])

    await pool.disconnect()
    #expect(await statuses.next() == [:])
    #expect(await statuses.next() == nil)
  }

  @Test
  func pendingJoinsCountTowardCapacityAndFailureIsIsolated() async throws {
    let pool = IRCConnectionPool(network: session)
    let pending = Task { try await pool.connect() }
    let first = await session.waitForTask(at: 0)
    await handshake(first)
    var messages = try await pending.value.makeAsyncIterator()

    for index in 0..<91 {
      try await pool.join(to: "channel\(index)")
    }

    let second = await session.waitForTask(at: 1)
    await handshake(second)
    await second.waitForSent("JOIN #channel90")
    await first.waitForSent("JOIN", count: 90)

    await first.simulateError(URLError(.networkConnectionLost))
    let replacement = await session.waitForTask(at: 2)
    #expect(await second.didCancel == false)

    await second.simulateIncoming(
      .string(":tester!tester@tester.tmi.twitch.tv JOIN #channel90"))
    let message = try #require(try await messages.next())

    if case .join(let join) = message {
      #expect(join.channel == "channel90")
    } else {
      Issue.record("Healthy socket stopped relaying")
    }

    try await pool.part(from: "channel0")
    await handshake(replacement)
    await replacement.waitForSent("JOIN", count: 89)

    #expect(await replacement.sentCount(prefix: "JOIN #channel0") == 0)

    await pool.disconnect()
  }

  @Test
  func joinDuringInitialHandshakeUsesOneConnection() async throws {
    let pool = IRCConnectionPool(network: session)
    let pending = Task { try await pool.connect() }
    let socket = await session.waitForTask(at: 0)
    try await pool.join(to: "swift")

    await handshake(socket)
    _ = try await pending.value
    await socket.waitForSent("JOIN #swift")

    #expect(await socket.sentCount(prefix: "JOIN #swift") == 1)
    #expect(await session.taskCount() == 1)

    await pool.disconnect()
  }

  @Test
  func writeConnectionRecoversAndAuthenticationFailureIsTerminal() async throws {
    let pending = Task {
      let client = TwitchIRCClient(.anonymous, network: session)

      try await client.connect()

      return client
    }

    let writer = await session.waitForTask(at: 0)
    await handshake(writer)
    let reader = await session.waitForTask(at: 1)
    await handshake(reader)
    let client = try await pending.value

    var messages = await client.messages().makeAsyncIterator()
    try await client.requestJoin(to: "swift")
    var statuses = await client.channelStatusSnapshots().makeAsyncIterator()
    _ = await statuses.next()

    let updates = await client.stateUpdates()
    await writer.simulateIncoming(.string(":tmi.twitch.tv RECONNECT"))
    _ = try #require(await updates.first { $0.status == .reconnecting })
    let replacement = await session.waitForTask(at: 2)
    await handshake(replacement)

    _ = try #require(await client.stateUpdates().first { $0.status == .connected })

    #expect(await reader.didCancel == false)

    await replacement.simulateIncoming(
      .string(
        ":tmi.twitch.tv NOTICE * :Login authentication failed"))
    let error = await #expect(throws: IRCError.self) { try await messages.next() }

    if case .loginFailed = error {
    } else {
      Issue.record("Expected terminal authentication failure")
    }

    #expect(await statuses.next() == ["swift": .failed(.authenticationFailed)])
    #expect(await statuses.next() == nil)
    await reader.waitForCancellation()
    await replacement.waitForCancellation()

    #expect(await reader.didCancel)
    #expect(await replacement.didCancel)

    await client.shutdown()
  }

  @Test
  func disconnectDuringAdditionalConnectionHandshake() async throws {
    let pool = IRCConnectionPool(network: session)
    let pending = Task { try await pool.connect() }
    let first = await session.waitForTask(at: 0)
    await handshake(first)
    _ = try await pending.value

    for index in 0..<91 {
      try await pool.join(to: "channel\(index)")
    }

    let second = await session.waitForTask(at: 1)
    await second.waitForSent("NICK")

    await pool.disconnect()
    await handshake(second)

    #expect(await second.didCancel)
    #expect(await second.sentCount(prefix: "JOIN") == 0)

    await #expect(throws: IRCError.self) { try await pool.join(to: "other") }
  }
}
