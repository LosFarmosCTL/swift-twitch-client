import Foundation
import Testing

@testable import Twitch

#if canImport(Combine)
  import Combine
#endif

private enum IRCFixtures {
  static let capabilitiesAck =
    ":tmi.twitch.tv CAP * ACK :twitch.tv/commands twitch.tv/tags"
  static let welcome =
    ":tmi.twitch.tv 001 justinfan12345 :Welcome, GLHF!"
  static let join =
    ":tester!tester@tester.tmi.twitch.tv JOIN #swift"
}

@Suite("IRC Tests", .timeLimit(.minutes(1)))
struct IRCTests {
  let session = MockNetworkSession()

  init() {}

  private func completeAnonymousHandshake(for task: MockWebSocketTask) async {
    await task.simulateIncoming(.string(IRCFixtures.capabilitiesAck))
    await task.simulateIncoming(.string(IRCFixtures.welcome))
  }

  @Test(
    "IRC client preserves its stream and rejoins after interruption",
    arguments: [false, true])
  func clientRecovers(serverReconnect: Bool) async throws {
    let clientTask = Task {
      let client = TwitchIRCClient(
        .anonymous, mode: .receiveOnly, network: session)

      try await client.connect()

      return client
    }

    let socket = await session.waitForTask(at: 0)
    await completeAnonymousHandshake(for: socket)
    let client = try await clientTask.value

    var messages = await client.messages().makeAsyncIterator()
    try await client.requestJoin(to: "swift")

    let updates = await client.stateUpdates()
    _ = try #require(await updates.first { $0.channels == ["swift": .joining] })

    var statuses = await client.channelStatusSnapshots().makeAsyncIterator()
    #expect(await statuses.next() == ["swift": .joining])

    await socket.simulateIncoming(
      .string(
        ":justinfan12345!justinfan12345@justinfan12345.tmi.twitch.tv JOIN #swift"))

    #expect(await statuses.next() == ["swift": .joined])
    _ = try await messages.next()

    if serverReconnect {
      await socket.simulateIncoming(.string(":tmi.twitch.tv RECONNECT"))
    } else {
      await socket.simulateError(URLError(.networkConnectionLost))
    }

    #expect(await statuses.next() == ["swift": .reconnecting])

    let replacement = await session.waitForTask(at: 1)
    await completeAnonymousHandshake(for: replacement)
    await replacement.waitForSent("JOIN #swift")
    await replacement.simulateIncoming(.string(IRCFixtures.join))

    let next = try #require(try await messages.next())

    guard case .join(let join) = next else {
      Issue.record("Expected message on the original stream")
      await client.shutdown()
      return
    }

    #expect(join.channel == "swift")
    #expect(await socket.didCancel)

    await client.shutdown()
  }

  @Test("IRC client fails during handshake and closes the socket")
  func clientFailsDuringHandshake() async throws {
    let clientTask = Task {
      let client = TwitchIRCClient(
        .anonymous,
        mode: .receiveOnly,
        network: session)

      try await client.connect()

      return client
    }

    let task = await session.waitForTask(at: 0)
    await task.simulateIncoming(
      .string(":tmi.twitch.tv NOTICE * :Login authentication failed"))

    let error = await #expect(throws: IRCError.self) {
      _ = try await clientTask.value
    }

    #expect(
      {
        if case .loginFailed = error {
          true
        } else {
          false
        }
      }())

    #expect(await task.didCancel)
  }

  @Test("IRC client disconnect closes sockets and finishes streams")
  func clientDisconnectShutsDownCleanly() async throws {
    let clientTask = Task {
      let client = TwitchIRCClient(.anonymous, network: session)

      try await client.connect()

      return client
    }

    let writeTask = await session.waitForTask(at: 0)
    await completeAnonymousHandshake(for: writeTask)

    let readTask = await session.waitForTask(at: 1)
    await completeAnonymousHandshake(for: readTask)

    let client = try await clientTask.value
    let stream = await client.messages()
    var iterator = stream.makeAsyncIterator()

    await client.shutdown()

    #expect(await readTask.didCancel)
    #expect(await writeTask.didCancel)

    let next = try await iterator.next()
    #expect(next == nil)

    let error = await #expect(throws: IRCError.self) {
      try await client.requestJoin(to: "swift")
    }

    #expect(
      {
        if case .disconnected = error {
          true
        } else {
          false
        }
      }())
  }

  @Test("IRC listener forwards messages and finishes on disconnect")
  func listenerForwardsMessagesAndFinishesOnDisconnect() async throws {
    let clientTask = Task {
      let client = TwitchIRCClient(
        .anonymous,
        mode: .receiveOnly,
        network: session)

      try await client.connect()

      return client
    }

    let task = await session.waitForTask(at: 0)
    await completeAnonymousHandshake(for: task)

    let client = try await clientTask.value

    await confirmation("Listener should receive message and finish", expectedCount: 2) {
      received in
      let receivedMessage = AsyncStream<Void>.makeStream()
      let finished = AsyncStream<Void>.makeStream()

      let cancellable = await client.listener { event in
        switch event {
        case .message(.join(let join)):
          #expect(join.channel == "swift")
          received()
          receivedMessage.continuation.finish()

        case .finished:
          received()
          finished.continuation.finish()

        case .message:
          break

        case .failure:
          Issue.record("Listener should not fail on explicit disconnect")
        }
      }

      await session.simulateIncoming(.string(IRCFixtures.join))
      _ = await receivedMessage.stream.first(where: { _ in true })

      await client.shutdown()
      _ = await finished.stream.first(where: { _ in true })

      _ = cancellable
    }
  }

  @Test("IRC listener fails after authentication failure")
  func listenerFailsAfterAuthenticationFailure() async throws {
    let clientTask = Task {
      let client = TwitchIRCClient(
        .anonymous,
        mode: .receiveOnly,
        network: session)

      try await client.connect()

      return client
    }

    let task = await session.waitForTask(at: 0)
    await completeAnonymousHandshake(for: task)

    let client = try await clientTask.value

    await confirmation("Listener should receive failure", expectedCount: 1) { received in
      let failed = AsyncStream<Void>.makeStream()

      let cancellable = await client.listener { event in
        guard case .failure(let error) = event else {
          return
        }

        #expect(
          {
            if case IRCError.loginFailed = error {
              true
            } else {
              false
            }
          }())

        received()
        failed.continuation.finish()
      }

      await task.simulateIncoming(
        .string(":tmi.twitch.tv NOTICE * :Login authentication failed"))
      _ = await failed.stream.first(where: { _ in true })

      _ = cancellable
    }
  }

  #if canImport(Combine)
    @Test("IRC publisher forwards messages and finishes on disconnect")
    func publisherForwardsMessages() async throws {
      let clientTask = Task {
        let client = TwitchIRCClient(
          .anonymous,
          mode: .receiveOnly,
          network: session)

        try await client.connect()

        return client
      }

      let task = await session.waitForTask(at: 0)
      await completeAnonymousHandshake(for: task)

      let client = try await clientTask.value

      await confirmation("Publisher should receive message and finish", expectedCount: 2)
      {
        received in
        let receivedMessage = AsyncStream<Void>.makeStream()

        let cancellable = await client.publisher().sink(
          receiveCompletion: { completion in
            guard case .finished = completion
            else {
              return
            }

            received()
            receivedMessage.continuation.finish()
          },
          receiveValue: { message in
            guard case .join(let join) = message else {
              return
            }

            #expect(join.channel == "swift")
            received()
            receivedMessage.continuation.finish()
          })

        await session.simulateIncoming(.string(IRCFixtures.join))
        _ = await receivedMessage.stream.first(where: { _ in true })

        await client.shutdown()

        _ = cancellable
      }
    }
  #endif
}
