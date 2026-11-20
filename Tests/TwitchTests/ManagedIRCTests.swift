import Foundation
import Testing
import TwitchIRC

@testable import Twitch

#if canImport(Combine)
  @preconcurrency import Combine
#endif

@Suite(.timeLimit(.minutes(1)))
struct ManagedIRCTests {
  let session = MockNetworkSession()
  let credentials = TwitchCredentials(
    accessToken: "token", clientID: "app", userID: UUID().uuidString, userLogin: "tester")
  let channel = ChatChannel(id: "123", login: "swift")

  func client() -> TwitchClient {
    TwitchClient(
      credentials: credentials, chat: .init(reader: .irc(.anonymous), writer: .irc),
      network: session)
  }

  func handshake(_ socket: MockWebSocketTask, authenticated: Bool = false) async {
    var frame =
      ":tmi.twitch.tv CAP * ACK :twitch.tv/commands twitch.tv/tags\r\n"
      + ":tmi.twitch.tv 001 tester :Welcome, GLHF!"

    if authenticated {
      frame +=
        "\r\n@badge-info=;badges=;emote-sets=0,123;user-id=\(credentials.userID!) :tmi.twitch.tv GLOBALUSERSTATE"
    }

    await socket.simulateIncoming(.string(frame))
  }

  func connect(_ client: TwitchClient) async throws -> MockWebSocketTask {
    let pending = Task { try await client.join(to: channel) }
    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    await acknowledge(socket)
    try await pending.value
    return socket
  }

  func acknowledge(_ socket: MockWebSocketTask) async {
    await socket.waitForSent("JOIN #swift")
    await socket.simulateIncoming(.string("@room-id=123 :tmi.twitch.tv ROOMSTATE #swift"))
  }

  func message(on socket: MockWebSocketTask) async {
    await socket.simulateIncoming(
      .string(
        "@display-name=Tester;user-id=42 :tester!tester@tester.tmi.twitch.tv PRIVMSG #swift :hello"
      ))
  }

  @Test(arguments: [false, true])
  func rawObserversSurviveReaderRecovery(serverReconnect: Bool) async throws {
    let client = client()
    let messages = await client.ircMessageStream()
    let socket = try await connect(client)
    let updates = await client.chatStateUpdates()

    if serverReconnect {
      await socket.simulateIncoming(.string(":tmi.twitch.tv RECONNECT"))
    } else {
      await socket.simulateError(URLError(.networkConnectionLost))
    }

    _ = try #require(await updates.first { $0.reader == .reconnecting })
    let replacement = await session.waitForTask(at: 1)
    await handshake(replacement)
    await acknowledge(replacement)
    await message(on: replacement)

    let received = try #require(
      await messages.first {
        if case .privateMessage = $0.message { true } else { false }
      })
    #expect(received.role == .read)
    #expect(await socket.didCancel)
    await client.shutdownChat()
  }

  @Test
  func writerAuthenticationFailureDoesNotEndHealthyReader() async throws {
    let client = client()
    let messages = await client.ircMessageStream()
    let reader = try await connect(client)
    let pending = Task {
      try await client.sendIRC(.privateMessage(to: "swift", message: "test"))
    }
    let writer = await session.waitForTask(at: 1)
    await writer.simulateIncoming(
      .string(":tmi.twitch.tv NOTICE * :Login authentication failed"))
    await #expect(throws: IRCError.self) { try await pending.value }

    #expect(await reader.didCancel == false)
    #expect(await client.chatState.channels[channel.id]?.status == .ready)
    await message(on: reader)
    _ = try #require(
      await messages.first {
        if case .privateMessage = $0.message { true } else { false }
      })
    await client.shutdownChat()
  }

  #if canImport(Combine)
    @Test
    func publisherSubscribersCancelIndependentlyOfRawObservers() async throws {
      let client = client()
      let raw = await client.ircMessageStream()
      let publisher = client.ircMessagePublisher()
      #expect(await session.taskCount() == 0)
      let first = publisher.sink { _ in }
      let received = AsyncStream<IRCMessage>.makeStream()
      let second = publisher.sink { received.continuation.yield($0) }
      first.cancel()

      let socket = try await connect(client)
      _ = try #require(
        await received.stream.first {
          if case .roomState = $0.message { true } else { false }
        })
      await message(on: socket)
      _ = try #require(
        await received.stream.first {
          if case .privateMessage = $0.message { true } else { false }
        })
      second.cancel()
      _ = try #require(
        await raw.first {
          if case .privateMessage = $0.message { true } else { false }
        })
      #expect(await socket.didCancel == false)
      let laterMessages = AsyncStream<IRCMessage>.makeStream()
      let later = publisher.sink { laterMessages.continuation.yield($0) }
      await message(on: socket)
      _ = try #require(
        await laterMessages.stream.first {
          if case .privateMessage = $0.message { true } else { false }
        })
      await client.shutdownChat()
      withExtendedLifetime(later) {}
    }

    @Test(arguments: [false, true])
    func publishersRetainCompletionAfterShutdownOrRootRelease(releaseRoot: Bool)
      async throws
    {
      var client: TwitchClient? = client()
      let publisher = try #require(client?.ircMessagePublisher())
      let completions = AsyncStream<Void>.makeStream()
      let subscription = publisher.sink(
        receiveCompletion: { _ in completions.continuation.finish() },
        receiveValue: { _ in Issue.record("Unexpected message without a transport") })

      if !releaseRoot { await client?.shutdownChat() }
      let latePublisher = try #require(client?.ircMessagePublisher())
      // The factory and its subscribers must not retain the root client.
      client = nil
      for await _ in completions.stream {}

      for publisher in [publisher, latePublisher] {
        await confirmation(expectedCount: 1) { completed in
          let late = publisher.sink(
            receiveCompletion: { _ in completed() }, receiveValue: { _ in })
          withExtendedLifetime(late) {}
        }
      }
      withExtendedLifetime(subscription) {}
    }
  #endif
}
