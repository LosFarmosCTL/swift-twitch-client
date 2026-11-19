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
      credentials: .init(accessToken: "", clientID: "", userID: "", userLogin: ""),
      network: session)

    let url = URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions")!
    await session.stub(
      url: url, method: "POST",
      status: 200, headers: ["Content-Type": "application/json"],
      body: MockedMessages.mockEventSubSubscription.data(using: .utf8)!)
    await session.stub(
      url: url.appending(queryItems: [
        URLQueryItem(name: "id", value: MockedMessages.defaultSubscriptionID)
      ]), method: "DELETE", status: 204)
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
    while await eventSubClient.subscriptionSetupWaiterCount < 2 {
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

  @Test("Streams and listeners share upstream ownership", .timeLimit(.minutes(1)))
  func sharedObserversReleaseOnlyTheirOwnOwnership() async throws {
    await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let stream = try await twitch.eventStream(for: .mock())
    let listenerEvents = AsyncStream<EventSubNotification<MockEvent>>.makeStream()
    let listener = try await twitch.eventListener(for: .mock()) { event in
      if case .event(let event) = event { listenerEvents.continuation.yield(event) }
    }
    let context = await twitch.eventSubClient
    #expect(await session.requestCount() == 1)

    let consumer = Task {
      for try await _ in stream {}
    }
    consumer.cancel()
    _ = await consumer.result
    while await context.subscriptionObserverCount != 1 { await Task.yield() }
    #expect(await session.requestCount() == 1)
    #expect(await session.lastTask()?.didCancel == false)

    await session.simulateIncoming(.string(MockedMessages.mockEventMessage))
    var events = listenerEvents.stream.makeAsyncIterator()
    _ = try #require(await events.next())

    let deleted = AsyncStream<Void>.makeStream()
    await session.onRequest { request in
      if request.httpMethod == "DELETE" { deleted.continuation.yield(()) }
    }
    listener.cancel()
    _ = await deleted.stream.first { _ in true }
    #expect(await session.requests().map(\.httpMethod) == ["POST", "DELETE"])
    let socket = try #require(await session.lastTask())
    await socket.waitForCancellation()
    #expect(await socket.didCancel)
  }

  @Test(
    "Revocation finishes all local owners without restoring them", .timeLimit(.minutes(1))
  )
  func revocationFinishesEverySharedObserver() async throws {
    await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let first = try await twitch.eventStream(for: .mock())
    let second = try await twitch.eventStream(for: .mock())
    #expect(await session.requestCount() == 1)

    await session.simulateIncoming(.string(MockedMessages.mockRevocationMessage))
    for stream in [first, second] {
      var iterator = stream.makeAsyncIterator()
      let error = await #expect(throws: EventSubError.self) {
        _ = try await iterator.next()
      }
      #expect({ if case .revocation = error { true } else { false } }())
    }
    #expect(await twitch.eventSubClient.subscriptionObserverCount == 0)
    #expect(await session.requestCount() == 1)
    let socket = try #require(await session.lastTask())
    await socket.waitForCancellation()
    #expect(await socket.didCancel)
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
      try await twitch.eventListener(for: .mock()) { _ in
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
    let cancellable = try await twitch.eventListener(for: .mock()) { event in
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
    @Test(
      "Publisher cancellation preserves its other subscribers and raw observers",
      .timeLimit(.minutes(1)))
    func publisherHasIndependentDownstreamOwnership() async throws {
      await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
      let raw = try await twitch.eventStream(for: .mock())
      let publisher = twitch.eventPublisher(for: .mock())
      let first = publisher.sink(receiveCompletion: { _ in }, receiveValue: { _ in })
      let events = AsyncStream<EventSubNotification<MockEvent>>.makeStream()
      let second = publisher.sink(
        receiveCompletion: { _ in }, receiveValue: { events.continuation.yield($0) })
      let context = await twitch.eventSubClient
      while await context.subscriptionObserverCount != 3 { await Task.yield() }
      first.cancel()
      while await context.subscriptionObserverCount != 2 { await Task.yield() }
      await session.simulateIncoming(.string(MockedMessages.mockEventMessage))
      var iterator = events.stream.makeAsyncIterator()
      _ = try #require(await iterator.next())
      #expect(await session.requestCount() == 1)

      second.cancel()
      while await context.subscriptionObserverCount != 1 { await Task.yield() }
      #expect(await session.requestCount() == 1)
      var rawIterator = raw.makeAsyncIterator()
      _ = try #require(try await rawIterator.next())
      await twitch.resetEventSub()
    }

    @Test("Publisher cancellation closes an unneeded handshake without completion")
    func testEventSubPublisherSetupCancellation() async throws {
      let handle = twitch.eventPublisher(for: .mock()).sink(
        receiveCompletion: { _ in Issue.record("Cancelled subscribers must not complete")
        },
        receiveValue: { _ in Issue.record("Cancelled subscribers must not receive events")
        })
      let socket = await session.waitForTask(at: 0)
      handle.cancel()
      await socket.waitForCancellation()
      await twitch.resetEventSub()
    }

    @Test("Client finishes EventSub publisher on reset")
    func testEventSubResetFinishesActivePublisher() async throws {
      await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
      let values = AsyncStream<EventSubNotification<MockEvent>>.makeStream()
      let finished = AsyncStream<Void>.makeStream()
      let cancellable = twitch.eventPublisher(for: .mock()).sink(
        receiveCompletion: { completion in
          if case .failure = completion {
            Issue.record("Publisher should finish normally on reset")
          }
          finished.continuation.finish()
        }, receiveValue: { values.continuation.yield($0) })
      let socket = await session.waitForTask(at: 0)
      while await session.requestCount() == 0 { await Task.yield() }
      await socket.simulateIncoming(.string(MockedMessages.mockEventMessage))
      _ = await values.stream.first { _ in true }
      await twitch.resetEventSub()
      _ = await finished.stream.first { _ in true }
      withExtendedLifetime(cancellable) {}
    }
  #endif
}
