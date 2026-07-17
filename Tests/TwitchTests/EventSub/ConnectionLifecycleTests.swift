import Foundation
import Testing

@testable import Twitch

#if canImport(Combine)
  @preconcurrency import Combine
#endif

@Suite("EventSub Connection Lifecycle Tests")
struct EventSubConnectionLifecycleTests {
  let twitch: TwitchClient
  let session: MockNetworkSession = MockNetworkSession()

  init() async {
    self.twitch = TwitchClient(
      authentication: .init(oAuth: "", clientID: "", userID: "", userLogin: ""),
      network: session)

    let url = URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions")!
    await session.stub(
      url: url, method: "POST",
      status: 200, headers: ["Content-Type": "application/json"],
      body: MockedMessages.mockEventSubSubscription.data(using: .utf8)!)
  }

  @Test(
    "Client reset cancels a pending EventSub handshake",
    .timeLimit(.minutes(1))
  )
  func testEventSubResetDuringPendingSetup() async throws {
    let setupTask = Task {
      try await twitch.eventStream(for: .mock())
    }

    let task = await session.waitForTask(at: 0)
    await twitch.resetEventSub()

    await #expect(throws: CancellationError.self) {
      _ = try await setupTask.value
    }

    #expect(await task.didCancel)

    await session.simulateIncoming(.string(MockedMessages.welcomeMessage), queue: true)
    let retriedStream = try await twitch.eventStream(for: .mock())
    #expect(await session.taskCount() == 2)

    await session.simulateIncoming(.string(MockedMessages.mockEventMessage))

    var retryIter = retriedStream.makeAsyncIterator()
    let message = try await retryIter.next()
    _ = try #require(message)
  }

  @Test(
    "Client setup cancellation closes an unneeded EventSub handshake",
    .timeLimit(.minutes(1))
  )
  func testEventSubStreamSetupCancellation() async throws {
    let setupTask = Task {
      try await twitch.eventStream(for: .mock())
    }

    let task = await session.waitForTask(at: 0)
    setupTask.cancel()

    await #expect(throws: CancellationError.self) {
      _ = try await setupTask.value
    }

    #expect(await task.didCancel)
  }

  @Test(
    "Cancelling one setup waiter keeps the shared EventSub handshake alive",
    .timeLimit(.minutes(1))
  )
  func testEventSubSharedSetupCancellation() async throws {
    let cancelledSetup = Task {
      try await twitch.eventStream(for: .mock())
    }

    let task = await session.waitForTask(at: 0)
    let remainingSetup = Task {
      try await twitch.eventStream(for: .mock())
    }

    let eventSubClient = await twitch.eventSubClient
    while await eventSubClient.connectionCreationWaiterCount < 2 {
      await Task.yield()
    }

    cancelledSetup.cancel()

    await #expect(throws: CancellationError.self) {
      _ = try await cancelledSetup.value
    }

    #expect(await task.didCancel == false)

    await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
    _ = try await remainingSetup.value

    #expect(await session.taskCount() == 1)
    await twitch.resetEventSub()
  }

  @Test("Client setup throws EventSubError when websocket disconnects before welcome")
  func testEventSubSetupDisconnectBeforeWelcome() async throws {
    let setupTask = Task {
      try await twitch.eventStream(for: .mock())
    }

    let task = await session.waitForTask(at: 0)
    await task.simulateError(WebSocketError.unsupportedDataReceived)

    let error = await #expect(throws: EventSubError.self) {
      _ = try await setupTask.value
    }

    #expect({ if case .disconnected = error { true } else { false } }())
  }

  @Test("Client finishes EventSub stream on reset")
  func testEventSubResetFinishesActiveStream() async throws {
    await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let stream = try await twitch.eventStream(for: .mock())

    await twitch.resetEventSub()

    var iter = stream.makeAsyncIterator()
    let next = try await iter.next()
    #expect(next == nil)
  }

  @Test("Client setup throws cancellation when EventSub listener setup is cancelled")
  func testEventSubListenerSetupCancellation() async throws {
    let setupTask = Task {
      try await twitch.eventListener(on: .mock()) { _ in
        Issue.record("Listener callback should not be called during setup cancellation")
      }
    }

    _ = await session.waitForTask(at: 0)
    setupTask.cancel()

    await #expect(throws: CancellationError.self) {
      _ = try await setupTask.value
    }

    await twitch.resetEventSub()
  }

  @Test("Client finishes EventSub listener on reset")
  func testEventSubResetFinishesActiveListener() async throws {
    await session.simulateIncoming(.string(MockedMessages.welcomeMessage))

    let finished = AsyncStream<Void>.makeStream()
    let cancellable = try await twitch.eventListener(on: .mock()) { event in
      switch event {
      case .finished:
        finished.continuation.finish()
      case .failure:
        Issue.record("Listener should finish normally on reset")
      case .event:
        break
      }
    }

    await twitch.resetEventSub()
    _ = await finished.stream.first(where: { _ in true })

    _ = cancellable
  }

  #if canImport(Combine)
    @Test("Client setup throws cancellation when EventSub publisher setup is cancelled")
    func testEventSubPublisherSetupCancellation() async throws {
      let cancelled = AsyncStream<Void>.makeStream()

      let setupTask = Task {
        do {
          _ = try await twitch.eventPublisher(for: .mock())
          Issue.record("Publisher setup should not succeed after cancellation")
        } catch is CancellationError {
          cancelled.continuation.yield(())
          cancelled.continuation.finish()
        } catch {
          Issue.record("Expected CancellationError, got \(error)")
        }
      }

      _ = await session.waitForTask(at: 0)
      setupTask.cancel()

      _ = await cancelled.stream.first(where: { _ in true })
      _ = await setupTask.result

      await twitch.resetEventSub()
    }

    @Test("Client finishes EventSub publisher on reset")
    func testEventSubResetFinishesActivePublisher() async throws {
      await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
      let publisher = try await twitch.eventPublisher(for: .mock())

      let finished = AsyncStream<Void>.makeStream()
      let cancellable = publisher.sink(
        receiveCompletion: { completion in
          switch completion {
          case .finished:
            finished.continuation.finish()
          case .failure:
            Issue.record("Publisher should finish normally on reset")
          }
        },
        receiveValue: { _ in }
      )

      await twitch.resetEventSub()
      _ = await finished.stream.first(where: { _ in true })

      _ = cancellable
    }
  #endif
}
