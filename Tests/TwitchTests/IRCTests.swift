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

@Suite("IRC Tests")
struct IRCTests {
  let session = MockNetworkSession()

  init() {}

  private func completeAnonymousHandshake(for task: MockWebSocketTask) async {
    await task.simulateIncoming(.string(IRCFixtures.capabilitiesAck))
    await task.simulateIncoming(.string(IRCFixtures.welcome))
  }

  private func settle(attempts: Int = 10) async {
    for _ in 0..<attempts {
      await Task.yield()
    }
  }

  @Test("IRC client fails loudly after socket failure")
  func clientFailsLoudlyAfterSocketFailure() async throws {
    let clientTask = Task {
      try await TwitchIRCClient(
        .anonymous,
        options: .init(enableWriteConnection: false),
        network: session)
    }

    let task = await session.waitForTask(at: 0)
    await completeAnonymousHandshake(for: task)

    let client = try await clientTask.value

    let stream = await client.stream()
    var iterator = stream.makeAsyncIterator()

    await task.simulateError(WebSocketError.unsupportedDataReceived)

    let streamError = await #expect(throws: WebSocketError.self) {
      _ = try await iterator.next()
    }

    #expect({ if case .unsupportedDataReceived = streamError { true } else { false } }())
    #expect(await task.didCancel)

    let joinError = await #expect(throws: WebSocketError.self) {
      try await client.join(to: "swift")
    }

    #expect({ if case .unsupportedDataReceived = joinError { true } else { false } }())
  }

  @Test("IRC client disconnect closes sockets and finishes streams")
  func clientDisconnectShutsDownCleanly() async throws {
    let clientTask = Task {
      try await TwitchIRCClient(.anonymous, network: session)
    }

    let writeTask = await session.waitForTask(at: 0)
    await completeAnonymousHandshake(for: writeTask)

    let readTask = await session.waitForTask(at: 1)
    await completeAnonymousHandshake(for: readTask)

    let client = try await clientTask.value
    let stream = await client.stream()
    var iterator = stream.makeAsyncIterator()

    await client.disconnect()

    #expect(await readTask.didCancel)
    #expect(await writeTask.didCancel)

    let next = try await iterator.next()
    #expect(next == nil)

    let error = await #expect(throws: IRCError.self) {
      try await client.join(to: "swift")
    }

    #expect({ if case .disconnected = error { true } else { false } }())
  }

  @Test("IRC listener forwards messages and finishes on disconnect")
  func listenerForwardsMessagesAndFinishesOnDisconnect() async throws {
    let clientTask = Task {
      try await TwitchIRCClient(
        .anonymous,
        options: .init(enableWriteConnection: false),
        network: session)
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

      await settle(attempts: 20)

      await session.simulateIncoming(.string(IRCFixtures.join))
      _ = await receivedMessage.stream.first(where: { _ in true })
      await client.disconnect()
      _ = await finished.stream.first(where: { _ in true })

      _ = cancellable
    }
  }

  @Test("IRC listener fails after socket failure")
  func listenerFailsAfterSocketFailure() async throws {
    let clientTask = Task {
      try await TwitchIRCClient(
        .anonymous,
        options: .init(enableWriteConnection: false),
        network: session)
    }

    let task = await session.waitForTask(at: 0)
    await completeAnonymousHandshake(for: task)

    let client = try await clientTask.value

    await confirmation("Listener should receive failure", expectedCount: 1) { received in
      let failed = AsyncStream<Void>.makeStream()
      let cancellable = await client.listener { event in
        guard case .failure(let error) = event else { return }
        #expect(
          {
            if case WebSocketError.unsupportedDataReceived = error { true } else { false }
          }())
        received()
        failed.continuation.finish()
      }

      await settle(attempts: 20)

      await task.simulateError(WebSocketError.unsupportedDataReceived)
      _ = await failed.stream.first(where: { _ in true })

      _ = cancellable
    }
  }

  #if canImport(Combine)
    @Test("IRC publisher forwards messages and finishes on disconnect")
    func publisherForwardsMessages() async throws {
      let clientTask = Task {
        try await TwitchIRCClient(
          .anonymous,
          options: .init(enableWriteConnection: false),
          network: session)
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
            guard case .join(let join) = message else { return }
            #expect(join.channel == "swift")
            received()
            receivedMessage.continuation.finish()
          })

        await settle(attempts: 20)

        await session.simulateIncoming(.string(IRCFixtures.join))
        _ = await receivedMessage.stream.first(where: { _ in true })
        await client.disconnect()

        _ = cancellable
      }
    }
  #endif
}
