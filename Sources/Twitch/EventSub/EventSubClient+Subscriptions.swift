import Foundation

extension EventSubClient {
  // MARK: - Subscription setup

  func startSubscription(_ key: ConflictKey) -> Subscription {
    let subscription = Subscription(
      key: key, credentials: credentials, revision: revision)
    subscriptions[key] = subscription
    subscription.setupTask = Task { await openSubscription(subscription) }
    return subscription
  }

  private func openSubscription(_ subscription: Subscription) async {
    var reservation: Reservation?
    var subscriptionID: String?
    var dispatched = false

    do {
      let (slot, sessionID) = try await reserveSubscriptionSlot(revision: subscription.revision)
      reservation = slot
      try checkRevision(subscription.revision)
      guard case .reserving = subscription.phase else { throw CancellationError() }
      subscription.phase = .posting(slot)

      let key = subscription.key
      let response = try await TwitchClient.helix(
        for: .createEventSubSubscription(
          using: .webSocket(id: sessionID),
          type: key.type,
          version: key.version,
          condition: key.condition),
        credentials: subscription.credentials,
        network: network,
        decoder: decoder,
        diagnostics: diagnostics,
        beforeDispatch: { dispatched = true })

      subscriptionID = response.value.subscription.id
      try activate(subscription, id: subscriptionID!)
    } catch {
      closeSubscription(subscription, error: setupError(error))

      if dispatched, subscriptionID == nil, let reservation, Self.isUncertainCreate(error) {
        reconcileCleanup(subscription, target: .unknownID, slot: reservation)
      } else {
        // A POST may succeed after the last observer has left.
        await deleteAndRemove(subscription, id: subscriptionID, slot: reservation)
      }
    }
  }

  private static func isUncertainCreate(_ error: any Error) -> Bool {
    let status: Int
    switch error {
    case HelixError.rateLimited: return false
    case HelixError.twitchError(_, let code, _), HelixError.parsingErrorFailed(let code, _):
      status = code
    default: return true
    }
    return status == 408 || !(400..<500).contains(status)
  }

  private func activate(_ subscription: Subscription, id: String) throws {
    try checkRevision(subscription.revision)
    guard case .posting(let slot) = subscription.phase else { throw CancellationError() }

    let buffered = try takePendingFrames(id, for: slot)
    subscription.phase = .active(id: id, slot: slot)
    subscription.setupTask = nil
    remoteSubscriptions[id] = subscription

    for frame in buffered { deliver(frame, to: subscription, in: slot.session) }
    for observer in subscription.observers.values { observer.markReady() }
  }

  private func setupError(_ error: any Error) -> any Error {
    switch error {
    case is CancellationError, is HelixError, is EventSubError: error
    default: EventSubError.disconnected(with: error)
    }
  }

  // MARK: - Subscription state

  struct ConflictKey: Hashable, Sendable {
    let account: String
    let type: String
    let version: String
    let condition: [String: String]
  }

  final class Subscription {
    enum Phase {
      case reserving
      case posting(Reservation)
      case active(id: String, slot: Reservation)
      case closing
    }

    let key: ConflictKey
    let credentials: TwitchCredentials
    let revision: UInt64

    var phase = Phase.reserving
    var observers: [UUID: Observer] = [:]
    var setupTask: Task<Void, Never>?
    var reconciliation: (slot: Reservation, target: CleanupTarget, task: Task<Void, Never>)?

    // A nil registry means this entry has finished cleanup.
    private(set) var cleanupWaiters: [UUID: AsyncThrowingStream<Void, any Error>.Continuation]? =
      [:]

    init(
      key: ConflictKey, credentials: TwitchCredentials, revision: UInt64
    ) {
      self.key = key
      self.credentials = credentials
      self.revision = revision
    }

    nonisolated(nonsending) func waitUntilClosed(until deadline: ContinuousClock.Instant)
      async throws
    {
      guard cleanupWaiters != nil else { return }

      let id = UUID()
      let (stream, completion) = AsyncThrowingStream<Void, any Error>.makeStream()
      cleanupWaiters?[id] = completion
      let timeout = Task {
        do {
          try await ContinuousClock().sleep(until: deadline)
          completion.finish(throwing: EventSubError.timedOut)
        } catch {}
      }
      defer {
        timeout.cancel()
        cleanupWaiters?[id] = nil
      }

      for try await _ in stream {}
    }

    func finishCleanup() {
      guard let waiters = cleanupWaiters?.values else { return }
      cleanupWaiters = nil

      for completion in waiters { completion.finish() }
    }
  }
}
