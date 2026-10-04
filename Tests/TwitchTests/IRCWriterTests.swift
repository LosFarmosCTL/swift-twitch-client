import Foundation
import Testing

@testable import Twitch

@Suite(.timeLimit(.minutes(1)))
struct IRCWriterTests {
  private let session = MockNetworkSession()

  private func handshake(_ socket: MockWebSocketTask) async {
    await socket.simulateIncoming(
      .string(
        ":tmi.twitch.tv CAP * ACK :twitch.tv/commands twitch.tv/tags\r\n"
          + ":tmi.twitch.tv 001 justinfan12345 :Welcome, GLHF!"))
  }

  @Test(arguments: [false, true])
  func writerRecoversWithoutReadMembership(serverRequested: Bool) async throws {
    let client = TwitchIRCClient(.anonymous, network: session)
    try await client.setDesiredChannels(["swift"])

    let pending = Task { try await client.connect() }
    let writer = await session.waitForTask(at: 0)
    await handshake(writer)
    let reader = await session.waitForTask(at: 1)
    await handshake(reader)
    try await pending.value

    try await client.setDesiredChannels([])
    await reader.waitForCancellation()
    try await client.sendMessage("before", to: "swift")
    #expect(await writer.sentCount(prefix: "PRIVMSG #swift :before") == 1)

    let updates = await client.stateUpdates()

    if serverRequested {
      await writer.simulateIncoming(.string(":tmi.twitch.tv RECONNECT"))
    } else {
      await writer.simulateError(URLError(.networkConnectionLost))
    }

    let recovering = try #require(await updates.first { $0.status == .reconnecting })
    let recovery = try #require(recovering.recoveries.first)
    #expect(recovering.channels.isEmpty)
    #expect(recovering.recoveries.count == 1)
    #expect(recovery.role == .write)
    #expect(recovery.channels.isEmpty)

    await #expect(throws: IRCError.self) {
      try await client.sendMessage("during", to: "swift")
    }

    let replacement = await session.waitForTask(at: 2)
    let recoveredUpdates = await client.stateUpdates()
    await handshake(replacement)
    _ = try #require(await recoveredUpdates.first { $0.status == .connected })

    try await client.sendMessage("after", to: "swift")
    #expect(await replacement.sentCount(prefix: "PRIVMSG #swift :after") == 1)
    #expect(await replacement.sentCount(prefix: "JOIN") == 0)
    #expect(await writer.sentCount(prefix: "JOIN") == 0)
    #expect(await writer.didCancel)
    await client.shutdown()
    #expect(await replacement.didCancel)
  }

  @Test
  func sendFailureDuringBackoffDoesNotAffectLaterRecovery() async throws {
    let supervisor = IRCConnectionSupervisor(network: session, role: .write)
    _ = try await supervisor.start()
    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    try await supervisor.waitUntilConnected()

    let sendStarted = AsyncStream<Void>.makeStream()
    let sendGate = AsyncStream<Void>.makeStream()
    let cancellationGate = AsyncStream<Void>.makeStream()

    await socket.onSend {
      sendStarted.continuation.finish()
      for await _ in sendGate.stream {}
      throw URLError(.badServerResponse)
    }

    // Hold the worker on the old socket until its pending send has failed.
    await socket.onCancellation {
      for await _ in cancellationGate.stream {}
    }

    let sending = Task { try await supervisor.send(.join(to: "swift")) }
    for await _ in sendStarted.stream {}

    let updates = await supervisor.stateUpdates()
    await socket.simulateIncoming(.string(":tmi.twitch.tv RECONNECT"))
    _ = try #require(await updates.first { $0.status == .reconnecting })

    sendGate.continuation.finish()
    let error = await #expect(throws: URLError.self) { try await sending.value }
    #expect(error?.code == .badServerResponse)
    cancellationGate.continuation.finish()

    let replacement = await session.waitForTask(at: 1)
    await handshake(replacement)
    try await supervisor.waitUntilConnected()

    let nextUpdates = await supervisor.stateUpdates()
    await replacement.simulateIncoming(.string(":tmi.twitch.tv RECONNECT"))
    let recovering = try #require(await nextUpdates.first { $0.status == .reconnecting })
    #expect(recovering.recoveries.first?.reason == .serverRequestedReconnect)

    await supervisor.disconnect()
  }

  @Test
  func cancelledSendDoesNotTransmitOrReconnectHealthySocket() async throws {
    let client = TwitchIRCClient(.anonymous, network: session)
    let pending = Task { try await client.connect() }
    let writer = await session.waitForTask(at: 0)
    await handshake(writer)
    let reader = await session.waitForTask(at: 1)
    await handshake(reader)
    try await pending.value

    let gate = AsyncStream<Void>.makeStream()
    let send = Task {
      for await _ in gate.stream {}
      try await client.sendMessage("cancelled", to: "swift")
    }

    send.cancel()
    gate.continuation.finish()
    await #expect(throws: CancellationError.self) { try await send.value }

    #expect(await writer.sentCount(prefix: "PRIVMSG") == 0)
    #expect(await writer.didCancel == false)

    try await client.sendMessage("still connected", to: "swift")
    #expect(await writer.sentCount(prefix: "PRIVMSG #swift :still connected") == 1)
    await client.shutdown()
  }
}
