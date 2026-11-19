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

  @Test
  func shutdownEndsJoinAndClosesPendingHandshake() async throws {
    let client = client()
    let pending = Task { try await client.join(to: ChatChannel(id: "123", login: "swift")) }
    let socket = await session.waitForTask(at: 0)
    await socket.waitForSent("NICK")

    await client.shutdownChat()
    await #expect(throws: ChatError.shutdown) { try await pending.value }
    await socket.waitForCancellation()
    #expect(await client.chatState.isShutdown)
  }

  @Test
  func endingChatDoesNotWaitForSocketCreation() async throws {
    let gate = AsyncTestGate()
    await session.onSocketCreation { await gate.pause() }

    let client = client()
    let pending = Task { try await client.join(to: ChatChannel(id: "123", login: "swift")) }
    let socket = await session.waitForTask(at: 0)

    await client.shutdownChat()
    await #expect(throws: ChatError.shutdown) { try await pending.value }
    await gate.waitUntilEntered()
    await gate.release()
    await socket.waitForCancellation()

    #expect(await socket.didResume == false)
    #expect(await socket.sentCount(prefix: "NICK") == 0)
  }

  private func client() -> TwitchClient {
    TwitchClient(
      credentials: .app(accessToken: "token", clientID: "app"),
      chat: .init(reader: .irc(.anonymous)), network: session)
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

}
