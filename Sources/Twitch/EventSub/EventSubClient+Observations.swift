import Foundation

extension EventSubClient {
  func observe<E: Event>(
    for requested: EventSubSubscription<E>,
    handler: any EventSubHandler,
    revision: UInt64
  ) async throws -> EventSubObservation {
    try checkRevision(revision)

    let key = ConflictKey(
      account: try credentials.requireUser().id,
      type: requested.type,
      version: requested.version,
      condition: requested.condition)

    try await waitForSubscriptionCleanup(key, revision: revision)
    try checkRevision(revision)

    let subscription = subscriptions[key] ?? startSubscription(key, eventType: E.self)
    let (observer, handle) = attachObserver(handler, to: subscription)

    do {
      try await observer.waitUntilReady()
      try checkRevision(revision)
      return handle
    } catch {
      await removeObservation(handle)
      throw error
    }
  }

  private func attachObserver(
    _ handler: any EventSubHandler,
    to subscription: Subscription
  ) -> (Observer, EventSubObservation) {
    let handle = EventSubObservation(key: subscription.key, id: UUID(), client: self)

    let observer = Observer(handler: handler)
    subscription.observers[handle.id] = observer

    if case .active = subscription.phase { observer.markReady() }
    return (observer, handle)
  }

  private func waitForSubscriptionCleanup(_ key: ConflictKey, revision: UInt64) async throws {
    while let previous = subscriptions[key], case .closing = previous.phase {
      await previous.waitUntilClosed()
      try checkRevision(revision)
    }
  }

  func removeObservation(_ observation: EventSubObservation) async {
    guard let subscription = subscriptions[observation.key] else { return }
    guard let observer = subscription.observers.removeValue(forKey: observation.id) else { return }

    observer.failSetup(CancellationError())
    guard subscription.observers.isEmpty else { return }

    // a caller cancelled during setup needs to wait for its abandoned socket reservation to unwind
    let reservationTask = findReservationTask(for: subscription)

    closeSubscription(subscription)
    await reservationTask?.value
  }

  private func findReservationTask(
    for subscription: EventSubClient.Subscription
  ) -> Task<Void, Never>? {
    if case .reserving = subscription.phase {
      return subscription.setupTask
    } else {
      return nil
    }
  }

  struct Observer {
    let handler: any EventSubHandler
    private let setup = AsyncThrowingStream<Void, any Error>.makeStream()

    init(handler: any EventSubHandler) { self.handler = handler }

    func waitUntilReady() async throws { for try await _ in setup.stream {} }

    func markReady() { setup.continuation.finish() }

    func failSetup(_ error: any Error) { setup.continuation.finish(throwing: error) }

    func finish(_ error: EventSubError?) {
      if let error { handler.finish(throwing: error) } else { handler.finish() }
    }
  }
}
