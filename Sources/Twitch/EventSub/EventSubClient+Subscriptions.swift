import Foundation

extension EventSubClient {
  // MARK: - Subscription setup

  func startSubscription(_ key: ConflictKey, eventType: any Event.Type) -> Subscription {
    let subscription = Subscription(
      key: key, eventType: eventType, credentials: credentials, revision: revision)
    subscriptions[key] = subscription
    subscription.setupTask = Task { await openSubscription(subscription) }
    return subscription
  }

  private func openSubscription(_ subscription: Subscription) async {
    var subscriptionID: String?

    do {
      let sessionID = try await reserveSession(for: subscription)

      let key = subscription.key
      let response = try await TwitchClient.helix(
        for: .createEventSubSubscription(
          using: .webSocket(id: sessionID),
          type: key.type,
          version: key.version,
          condition: key.condition),
        credentials: subscription.credentials,
        network: network,
        decoder: decoder)

      subscriptionID = response.value.subscription.id
      try activate(subscription, id: subscriptionID!)
    } catch {
      closeSubscription(subscription, error: setupError(error))

      // a POST may succeed after the last observer has left.
      await deleteAndRemove(subscription, id: subscriptionID)
    }
  }

  private func reserveSession(for subscription: Subscription) async throws -> String {
    let (slot, sessionID) = try await reserveSubscriptionSlot(revision: subscription.revision)
    subscription.phase = .posting(slot)
    return sessionID
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
    let eventType: any Event.Type
    let credentials: TwitchCredentials
    let revision: UInt64

    var phase = Phase.reserving
    var observers: [UUID: Observer] = [:]
    var setupTask: Task<Void, Never>?

    // A nil registry means this entry has finished cleanup.
    private(set) var cleanupWaiters: [UUID: AsyncStream<Void>.Continuation]? = [:]

    init(
      key: ConflictKey, eventType: any Event.Type, credentials: TwitchCredentials, revision: UInt64
    ) {
      self.key = key
      self.eventType = eventType
      self.credentials = credentials
      self.revision = revision
    }

    nonisolated(nonsending) func waitUntilClosed() async {
      guard cleanupWaiters != nil else { return }

      let id = UUID()
      let (stream, completion) = AsyncStream<Void>.makeStream()
      cleanupWaiters?[id] = completion
      defer { cleanupWaiters?[id] = nil }

      for await _ in stream {}
    }

    func finishCleanup() {
      guard let waiters = cleanupWaiters?.values else { return }
      cleanupWaiters = nil

      for completion in waiters { completion.finish() }
    }
  }
}
