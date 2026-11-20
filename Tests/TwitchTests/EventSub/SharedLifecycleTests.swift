import Foundation
import Testing

@testable import Twitch

@Suite("Shared EventSub lifecycle", .timeLimit(.minutes(1)))
struct SharedEventSubLifecycleTests {
  private let url = URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions")!
  private let sessionID = "111111111111111111111111111111111111"

  private func welcome(_ id: String) -> String {
    MockedMessages.welcomeMessage.replacingOccurrences(of: sessionID, with: id)
  }

  private func stubSubscription(
    _ network: MockNetworkSession, id: String = MockedMessages.defaultSubscriptionID
  ) async {
    await network.stub(
      url: url, method: "POST",
      body: Data(
        MockedMessages.customized(
          MockedMessages.mockEventSubSubscription, subscriptionID: id
        ).utf8))
    await network.stub(
      url: url.appending(queryItems: [.init(name: "id", value: id)]),
      method: "DELETE", status: 204)
  }

  @Test("Handoff drains observers, deduplicates notifications and preserves pending setup")
  func handoffWithPendingSubscription() async throws {
    let harness = EventTestHarness()
    await stubSubscription(harness.session, id: MockedMessages.defaultSubscriptionID)
    await harness.session.simulateIncoming(.string(welcome(sessionID)), queue: true)
    let first = try await harness.twitch.eventStream(for: .mock())
    let old = await harness.session.waitForTask(at: 0)

    let secondID = "pending-subscription"
    await stubSubscription(harness.session, id: secondID)
    let gate = AsyncTestGate()
    await harness.session.onRequest {
      if $0.httpMethod == "POST" { await gate.pause() }
    }
    let setup = Task { try await harness.twitch.eventStream(for: .mock(version: "2")) }
    await gate.waitUntilEntered()
    let earlyEvents = AsyncStream<EventSubNotification<MockEvent>>.makeStream()
    async let earlyListener = harness.twitch.eventListener(for: .mock(version: "2")) {
      if case .event(let event) = $0 { earlyEvents.continuation.yield(event) }
    }
    let context = await harness.twitch.eventSubClient
    while await context.subscriptionSetupWaiterCount != 2 { await Task.yield() }

    await old.simulateIncoming(.string(MockedMessages.mockReconnectMessage))
    let replacement = await harness.session.waitForTask(at: 1)
    let early = MockedMessages.customized(
      MockedMessages.mockVersion2EventMessage,
      messageID: "before-post-response", subscriptionID: secondID)
    await old.simulateIncoming(.string(early))
    await old.simulateIncoming(.string(MockedMessages.mockEventMessage))
    var firstIterator = first.makeAsyncIterator()
    _ = try #require(try await firstIterator.next())
    #expect(await !old.didCancel)

    await replacement.simulateIncoming(.string(welcome("replacement")))
    await old.waitForCancellation()
    await gate.release()
    let second = try await setup.value
    let listener = try await earlyListener
    var secondIterator = second.makeAsyncIterator()
    // The pending subscription can receive a frame before its POST returns.
    let buffered = try #require(try await secondIterator.next())
    try expectMetadata(buffered, messageID: "before-post-response", subscriptionID: secondID)
    let sharedBuffered = try #require(await earlyEvents.stream.first { _ in true })
    #expect(buffered.event.decodingID == sharedBuffered.event.decodingID)

    // The old socket already delivered this envelope. The following notification
    // establishes that the replacement processed the replay before reset.
    await replacement.simulateIncoming(.string(MockedMessages.mockEventMessage))
    let afterHandoff = MockedMessages.customized(
      MockedMessages.mockVersion2EventMessage, messageID: "after-handoff", subscriptionID: secondID)
    await replacement.simulateIncoming(.string(afterHandoff))
    let afterHandoffNotification = try #require(try await secondIterator.next())
    #expect(afterHandoffNotification.messageID == "after-handoff")
    #expect(
      await harness.session.requests().filter { $0.httpMethod == "POST" }.count == 2)
    await harness.twitch.resetEventSub()
    #expect(try await firstIterator.next() == nil)
    withExtendedLifetime(listener) {}
  }

  @Test("Parallel reservations respect capacity, cancellation, and retirement")
  func capacity() async throws {
    let network = MockNetworkSession()
    let client = EventSubClient(
      network: network, decoder: TwitchClient.makeDecoder(),
      credentials: .init(accessToken: "", clientID: "", userID: "", userLogin: ""))
    let results = AsyncStream<EventSubClient.Reservation>.makeStream()
    let requests = (0..<901).map { _ in
      Task {
        let (slot, _) = try await client.reserveSubscriptionSlot()
        results.continuation.yield(slot)
        return slot
      }
    }
    while await client.connectionCreationWaiterCount != 901 { await Task.yield() }
    for index in 0..<3 {
      let socket = await network.waitForTask(at: index)
      await socket.simulateIncoming(.string(welcome("session-\(index)")))
    }
    while await client.connectionCreationWaiterCount != 1 { await Task.yield() }
    var iterator = results.stream.makeAsyncIterator()
    var granted = [EventSubClient.Reservation]()
    for _ in 0..<900 { granted.append(try #require(await iterator.next())) }
    #expect(
      Dictionary(grouping: granted, by: \.session).values.map(\.count).sorted()
        == [300, 300, 300])
    #expect(await network.taskCount() == 3)

    let cancelled = Task { try await client.reserveSubscriptionSlot() }
    while await client.connectionCreationWaiterCount != 2 { await Task.yield() }
    cancelled.cancel()
    await #expect(throws: CancellationError.self) { _ = try await cancelled.value }
    await client.releaseReservation(granted[0])
    #expect(await iterator.next()?.session == granted[0].session)
    for request in requests { _ = try await request.value }
    let pending = Task { try await client.reserveSubscriptionSlot() }
    while await client.connectionCreationWaiterCount != 1 { await Task.yield() }
    await client.retire()
    await #expect(throws: CancellationError.self) { _ = try await pending.value }
    for index in 0..<3 { #expect(await network.task(at: index)?.didCancel == true) }
  }

  @Test("Reset closes both handoff transports and ignores a late replacement welcome")
  func resetDuringHandoff() async throws {
    let harness = EventTestHarness()
    await stubSubscription(harness.session, id: MockedMessages.defaultSubscriptionID)
    await harness.session.simulateIncoming(.string(welcome(sessionID)), queue: true)
    let stream = try await harness.twitch.eventStream(for: .mock())
    let old = await harness.session.waitForTask(at: 0)
    await old.simulateIncoming(.string(MockedMessages.mockReconnectMessage))
    let replacement = await harness.session.waitForTask(at: 1)
    await harness.twitch.resetEventSub()
    #expect(await old.didCancel)
    #expect(await replacement.didCancel)
    var iterator = stream.makeAsyncIterator()
    #expect(try await iterator.next() == nil)
    await replacement.simulateIncoming(.string(welcome("stale-session")))
    await harness.session.simulateIncoming(.string(welcome("fresh-session")), queue: true)
    _ = try await harness.twitch.eventStream(for: .mock())
    #expect(await harness.session.taskCount() == 3)
    await harness.twitch.resetEventSub()
  }

  @Test(
    "Failure releases shared callback captures and delivers no later finish",
    arguments: [false, true])
  func terminalCleanup(revoked: Bool) async throws {
    let harness = EventTestHarness()
    await stubSubscription(harness.session, id: MockedMessages.defaultSubscriptionID)
    await harness.session.simulateIncoming(.string(welcome(sessionID)), queue: true)
    let released = AsyncStream<Void>.makeStream()
    let terminal = AsyncStream<Void>.makeStream()
    try await confirmation("One terminal outcome per observer", expectedCount: 2) {
      confirm in
      func register() async throws -> TwitchCancellable {
        let capture = EventSubLifetimeProbe(released: released.continuation)
        return try await harness.twitch.eventListener(for: .mock()) { [capture] event in
          withExtendedLifetime(capture) {
            switch event {
            case .event: break
            case .failure:
              confirm()
              terminal.continuation.yield(())
            case .finished:
              confirm()
              Issue.record("Failure must not be followed by finished")
            }
          }
        }
      }
      let first = try await register()
      let second = try await register()
      let socket = await harness.session.waitForTask(at: 0)
      if revoked {
        await socket.simulateIncoming(.string(MockedMessages.mockRevocationMessage))
      } else {
        await socket.simulateError(WebSocketError.unsupportedDataReceived)
      }
      var outcomes = terminal.stream.makeAsyncIterator()
      var releases = released.stream.makeAsyncIterator()
      for _ in 0..<2 {
        _ = await outcomes.next()
        _ = await releases.next()
      }
      await harness.twitch.resetEventSub()
      withExtendedLifetime((first, second)) {}
    }
  }

  @Test("Stream buffering defaults to unbounded and honors selected drop policies")
  func buffering() async throws {
    let harness = EventTestHarness()
    let policies:
      [AsyncThrowingStream<EventSubNotification<StreamOnlineEvent>, any Error>.Continuation
        .BufferingPolicy] =
        [
          .unbounded, .bufferingNewest(2), .bufferingOldest(2),
        ]
    for (index, policy) in policies.enumerated() {
      await stubSubscription(harness.session)
      await harness.session.simulateIncoming(
        .string(welcome(sessionID)), queue: true)
      let stream: AsyncThrowingStream<EventSubNotification<StreamOnlineEvent>, any Error>
      if index == 0 {
        stream = try await harness.twitch.eventStream(
          for: .streamOnline(broadcasterID: "1337"))
      } else {
        stream = try await harness.twitch.eventStream(
          for: .streamOnline(broadcasterID: "1337"), bufferingPolicy: policy)
      }
      let markerID = "buffer-marker"
      await stubSubscription(harness.session, id: markerID)
      let drained = AsyncStream<Void>.makeStream()
      let handle = try await harness.twitch.eventListener(for: .mock()) { event in
        if case .event = event { drained.continuation.yield(()) }
      }
      for value in 0..<5 {
        await harness.session.simulateIncoming(
          .string(
            MockedMessages.customized(
              MockedMessages.streamOnline.replacingOccurrences(
                of: "9001", with: "\(value)"),
              messageID: "buffer-\(value)")))
      }
      // The serial receive loop delivers this only after every preceding event.
      await harness.session.simulateIncoming(
        .string(
          MockedMessages.customized(
            MockedMessages.mockEventMessage, messageID: "marker", subscriptionID: markerID
          )))
      _ = await drained.stream.first { _ in true }
      await harness.twitch.resetEventSub()
      var ids = [String]()
      for try await notification in stream { ids.append(notification.event.id) }
      #expect(
        ids
          == (index == 0
            ? ["0", "1", "2", "3", "4"] : index == 1 ? ["3", "4"] : ["0", "1"]))
      withExtendedLifetime(handle) {}
    }
  }

  @Test("A retained handle does not keep the owning client or socket alive")
  func ownerLifetime() async throws {
    let network = MockNetworkSession()
    await stubSubscription(network, id: MockedMessages.defaultSubscriptionID)
    var owner: TwitchClient? = TwitchClient(
      credentials: .init(accessToken: "", clientID: "", userID: "", userLogin: ""),
      network: network)
    weak let weakOwner = owner
    let finished = AsyncStream<Void>.makeStream()
    await network.simulateIncoming(.string(welcome(sessionID)), queue: true)
    let handle = try await owner!.eventListener(for: .mock()) {
      if case .finished = $0 { finished.continuation.yield(()) }
    }
    let socket = await network.waitForTask(at: 0)
    owner = nil
    _ = await finished.stream.first { _ in true }
    await socket.waitForCancellation()
    #expect(weakOwner == nil)
    withExtendedLifetime(handle) {}
  }
}

extension SharedEventSubLifecycleTests {
  @Test("A pending DELETE still occupies capacity on a socket that stays open")
  func pendingDeletionReservesCapacity() async throws {
    let harness = EventTestHarness()
    await stubSubscription(harness.session)
    await harness.session.simulateIncoming(.string(welcome(sessionID)), queue: true)
    let handle = try await harness.twitch.eventListener(for: .mock()) { _ in }
    let oldSocket = await harness.session.waitForTask(at: 0)
    let coordinator = await harness.twitch.eventSubClient
    for _ in 0..<299 {
      _ = try await coordinator.reserveSubscriptionSlot()
    }

    let gate = AsyncTestGate()
    await harness.session.onRequest { request in
      if request.httpMethod == "DELETE" { await gate.pause() }
    }
    handle.cancel()
    await gate.waitUntilEntered()

    await harness.session.simulateIncoming(.string(welcome("new-session")), queue: true)
    let next = try? await coordinator.reserveSubscriptionSlot()
    #expect(await !oldSocket.didCancel)

    await gate.release()
    await harness.twitch.resetEventSub()
    #expect(next?.sessionID == "new-session")
  }

  @Test("Slow deletion releases the socket and only delays a conflicting subscription")
  func slowDeletion() async throws {
    let original = TwitchCredentials(
      accessToken: "original", clientID: "app", userID: "user", userLogin: "user")
    let updated = TwitchCredentials(
      accessToken: "updated", clientID: "app", userID: "user", userLogin: "user")
    let harness = EventTestHarness(credentials: original)
    let client = harness.twitch
    let network = harness.session
    let oldID = MockedMessages.defaultSubscriptionID
    await stubSubscription(network, id: oldID)
    await network.simulateIncoming(.string(welcome(sessionID)), queue: true)
    let handle = try await client.eventListener(for: .mock()) { _ in }
    let oldSocket = await network.waitForTask(at: 0)
    let gate = AsyncTestGate()
    await network.onRequest { request in
      if request.httpMethod == "DELETE", request.url?.query?.contains(oldID) == true {
        await gate.pause()
      }
    }

    handle.cancel()
    await gate.waitUntilEntered()
    await oldSocket.waitForCancellation()

    let coordinator = await client.eventSubClient
    let superseded = Task { try await client.eventStream(for: .mock()) }
    while await coordinator.subscriptionSetupWaiterCount != 1 { await Task.yield() }
    await client.switchCredentials(to: updated)

    let conflicting = Task { try await client.eventStream(for: .mock()) }
    while await coordinator.subscriptionSetupWaiterCount != 2 { await Task.yield() }
    await stubSubscription(network, id: "unrelated")
    await network.simulateIncoming(.string(welcome("new-session")), queue: true)
    let unrelated = try await client.eventStream(for: .mock(version: "2"))
    let pending = await network.requests()
    #expect(pending.map(\.httpMethod) == ["POST", "DELETE", "POST"])
    #expect(pending[1].value(forHTTPHeaderField: "Authorization") == "Bearer original")
    #expect(pending[2].value(forHTTPHeaderField: "Authorization") == "Bearer updated")
    #expect(await network.taskCount() == 2)

    await stubSubscription(network, id: "replacement")
    await gate.release()
    await #expect(throws: CancellationError.self) { _ = try await superseded.value }
    let replacement = try await conflicting.value
    #expect(await network.requests().map(\.httpMethod) == ["POST", "DELETE", "POST", "POST"])
    #expect(await network.taskCount() == 2)
    await client.resetEventSub()
    withExtendedLifetime((unrelated, replacement)) {}
  }
}

private func expectMetadata(
  _ notification: EventSubNotification<MockEvent>,
  messageID: String = MockedMessages.defaultEventMessageID,
  subscriptionID: String = MockedMessages.defaultSubscriptionID,
  sourceLocation: SourceLocation = #_sourceLocation
) throws {
  let sentAt = try Date(
    "2025-08-30T01:10:13.390973799Z",
    strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true))

  #expect(notification.sentAt == sentAt, sourceLocation: sourceLocation)
  #expect(notification.messageID == messageID, sourceLocation: sourceLocation)
  #expect(notification.subscriptionID == subscriptionID, sourceLocation: sourceLocation)
}

private final class EventSubLifetimeProbe: Sendable {
  let released: AsyncStream<Void>.Continuation
  init(released: AsyncStream<Void>.Continuation) { self.released = released }
  deinit { released.yield(()) }
}
