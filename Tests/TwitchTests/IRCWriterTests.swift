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
    let credentials = TwitchCredentials(
      accessToken: "token", clientID: "app", userID: UUID().uuidString, userLogin: "tester")
    let client = TwitchClient(credentials: credentials, chat: .init(writer: .irc), network: session)
    let pending = Task { try await client.sendIRC(.privateMessage(to: "swift", message: "before")) }
    let writer = await session.waitForTask(at: 0)
    await writer.simulateIncoming(
      .string(
        ":tmi.twitch.tv CAP * ACK :twitch.tv/commands twitch.tv/tags\r\n"
          + ":tmi.twitch.tv 001 tester :Welcome\r\n"
          + "@emote-sets=0;user-id=tester :tmi.twitch.tv GLOBALUSERSTATE"))
    try await pending.value

    let updates = await client.chatStateUpdates()
    if serverRequested {
      await writer.simulateIncoming(.string(":tmi.twitch.tv RECONNECT"))
    } else {
      await writer.simulateError(URLError(.networkConnectionLost))
    }

    let recovering = try #require(await updates.first { $0.writer == .reconnecting })
    #expect(recovering.reader == .idle)
    #expect(recovering.channels.isEmpty)
    #expect(recovering.ircWriter?.recoveries.first?.role == .write)

    let send = Task { try await client.sendIRC(.privateMessage(to: "swift", message: "after")) }
    let replacement = await session.waitForTask(at: 1)
    await replacement.simulateIncoming(
      .string(
        ":tmi.twitch.tv CAP * ACK :twitch.tv/commands twitch.tv/tags\r\n"
          + ":tmi.twitch.tv 001 tester :Welcome\r\n"
          + "@emote-sets=0;user-id=tester :tmi.twitch.tv GLOBALUSERSTATE"))
    try await send.value

    #expect(await replacement.sentCount(prefix: "PRIVMSG #swift :after") == 1)
    #expect(await replacement.sentCount(prefix: "JOIN") == 0)
    #expect(await writer.didCancel)
    await client.shutdownChat()
    #expect(await replacement.didCancel)
  }

  @Test
  func sendFailureDuringBackoffDoesNotAffectLaterRecovery() async throws {
    let supervisor = IRCConnectionSupervisor(network: session, role: .write)
    let updates = try await supervisor.start()
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

    await socket.simulateIncoming(.string(":tmi.twitch.tv RECONNECT"))
    _ = try #require(try await updates.nextState { $0.status == .reconnecting })

    sendGate.continuation.finish()
    let error = await #expect(throws: URLError.self) { try await sending.value }
    #expect(error?.code == .badServerResponse)
    cancellationGate.continuation.finish()

    let replacement = await session.waitForTask(at: 1)
    await handshake(replacement)
    try await supervisor.waitUntilConnected()

    await replacement.simulateIncoming(.string(":tmi.twitch.tv RECONNECT"))
    let recovering = try #require(try await updates.nextState { $0.status == .reconnecting })
    #expect(recovering.recoveries.first?.reason == .serverRequestedReconnect)

    await supervisor.disconnect()
  }

}
