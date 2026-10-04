import Foundation
import Testing

@testable import Twitch

@Suite(.timeLimit(.minutes(1)))
struct IRCConnectionSetupTests {
  private let session = MockNetworkSession()

  private func handshake(_ socket: MockWebSocketTask) async {
    await socket.simulateIncoming(
      .string(
        ":tmi.twitch.tv CAP * ACK :twitch.tv/commands twitch.tv/tags\r\n"
          + ":tmi.twitch.tv 001 justinfan12345 :Welcome, GLHF!"))
  }

  @Test(arguments: [false, true])
  func shutdownInterruptsPendingSetup(waitingForReader: Bool) async throws {
    let client = TwitchIRCClient(.anonymous, network: session)
    let pending = Task { try await client.connect() }
    let writer = await session.waitForTask(at: 0)
    await writer.waitForSent("NICK")
    var reader: MockWebSocketTask?

    if waitingForReader {
      await handshake(writer)
      reader = await session.waitForTask(at: 1)
      await reader?.waitForSent("NICK")
    }

    await client.shutdown()
    let error = await #expect(throws: IRCError.self) { try await pending.value }

    if case .disconnected = error {
    } else {
      Issue.record("Explicit shutdown should interrupt setup with disconnected")
    }

    #expect(await client.state.status == .shutdown)
    #expect(await writer.didCancel)

    if let reader {
      #expect(await reader.didCancel)
    }

    await #expect(throws: IRCError.self) { try await client.connect() }
  }

  @Test(arguments: [false, true])
  func endingSessionDoesNotWaitForSocketCreation(cancelCaller: Bool) async throws {
    let gate = AsyncStream<Void>.makeStream()
    await session.onSocketCreation {
      for await _ in gate.stream {}
    }

    let client = TwitchIRCClient(.anonymous, network: session)
    let pending = Task { try await client.connect() }
    let socket = await session.waitForTask(at: 0)

    if cancelCaller {
      pending.cancel()
      await #expect(throws: CancellationError.self) { try await pending.value }
    } else {
      await client.shutdown()
      await #expect(throws: IRCError.self) { try await pending.value }
    }

    #expect(await client.state.status == .shutdown)
    gate.continuation.finish()
    await socket.waitForCancellation()

    #expect(await socket.didResume == false)
    #expect(await socket.sentCount(prefix: "NICK") == 0)
    await #expect(throws: IRCError.self) { try await client.connect() }
  }

  @Test
  func lateSocketCreationCannotCloseReplacementConnection() async throws {
    let gate = AsyncStream<Void>.makeStream()
    await session.onSocketCreation {
      for await _ in gate.stream {}
    }

    let connection = IRCConnection(network: session)
    let oldConnect = Task { try await connection.connect() }
    let oldSocket = await session.waitForTask(at: 0)
    #expect(oldSocket.url.absoluteString == "wss://irc-ws.chat.twitch.tv:443")

    await connection.disconnect()
    await session.onSocketCreation(nil)

    let newConnect = Task { try await connection.connect() }
    let newSocket = await session.waitForTask(at: 1)
    await handshake(newSocket)
    _ = try await newConnect.value

    gate.continuation.finish()
    await #expect(throws: CancellationError.self) { try await oldConnect.value }

    #expect(await oldSocket.didCancel)
    #expect(await oldSocket.didResume == false)
    #expect(await newSocket.didCancel == false)

    try await connection.send(.join(to: "swift"))
    #expect(await newSocket.sentCount(prefix: "JOIN #swift") == 1)

    await connection.disconnect()
  }

  @Test
  func cancelledConnectDoesNotStartSession() async throws {
    let client = TwitchIRCClient(.anonymous, network: session)
    let gate = AsyncStream<Void>.makeStream()
    let pending = Task {
      for await _ in gate.stream {}
      try await client.connect()
    }

    pending.cancel()
    gate.continuation.finish()
    await #expect(throws: CancellationError.self) { try await pending.value }

    #expect(await session.taskCount() == 0)
    #expect(await client.state.status == .idle)

    await client.shutdown()
  }
}
