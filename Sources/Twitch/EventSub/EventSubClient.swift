import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

private typealias SubscriptionID = String
private typealias SessionID = String

internal actor EventSubClient {
  private struct ConnectionCreation {
    let id: UUID
    let task: Task<SessionID, Error>
    var isCancellationRequested = false
  }

  private static let eventSubURL = URL(string: "wss://eventsub.wss.twitch.tv/ws")!
  private static let maxSubscriptionsPerConnection = 300

  private let network: NetworkSession
  private let decoder: JSONDecoder

  private var connections = [SessionID: EventSubConnection]()
  private var connectionSubscriptions = [SessionID: [SubscriptionID]]()
  private var eventHandlers = [SubscriptionID: EventSubHandler]()

  private var pendingEvents = [SubscriptionID: [Event]]()
  private var pendingErrors = [SubscriptionID: EventSubError]()

  private var reservedSlots = [SessionID: Int]()
  private var connectionCreation: ConnectionCreation?
  private var connectionCreationWaiters =
    [UUID: CheckedContinuation<SessionID, Error>]()

  private var isResetting = false
  private var isRetired = false

  internal init(
    network: NetworkSession,
    decoder: JSONDecoder
  ) {
    self.network = network
    self.decoder = decoder
  }

  internal func addHandler(
    _ handler: EventSubHandler, for subscriptionID: String, on sessionID: String
  ) -> Bool {
    guard !isRetired, !isResetting, connections[sessionID] != nil else { return false }
    consumeReservation(for: sessionID)

    eventHandlers[subscriptionID] = handler
    connectionSubscriptions[sessionID, default: []].append(subscriptionID)

    // if events were received before the handler was registered, yield them
    if let pendingEvents = pendingEvents.removeValue(forKey: subscriptionID) {
      for event in pendingEvents {
        handler.yield(event)
      }
    }

    if let pendingError = pendingErrors.removeValue(forKey: subscriptionID) {
      handler.finish(throwing: pendingError)
    }
    return true
  }

  internal func removeHandler(for subscriptionID: String) async {
    eventHandlers.removeValue(forKey: subscriptionID)
    pendingEvents.removeValue(forKey: subscriptionID)
    pendingErrors.removeValue(forKey: subscriptionID)

    if let sessionID = sessionID(for: subscriptionID) {
      connectionSubscriptions[sessionID] =
        connectionSubscriptions[sessionID]?.filter { $0 != subscriptionID }

      // if no more events are subscribed to the socket, close the connection
      await closeConnectionIfUnused(sessionID)
    }
  }

  internal func reserveWebSocketSessionID() async throws -> String {
    while true {
      try Task.checkCancellation()
      guard !isResetting, !isRetired else { throw CancellationError() }

      let sessionID = connections.keys.first(where: hasFreeCapacity)
      if let sessionID {
        reservedSlots[sessionID, default: 0] += 1
        return sessionID
      }

      if let creation = connectionCreation,
        creation.isCancellationRequested || creation.task.isCancelled
      {
        let result = await creation.task.result
        await finishConnectionCreation(id: creation.id, with: result)
        continue
      }

      if connectionCreation == nil { startConnectionCreation() }

      return try await waitForConnectionCreation()
    }
  }

  internal var connectionCreationWaiterCount: Int {
    connectionCreationWaiters.count
  }

  internal func releaseReservation(for sessionID: String) async {
    consumeReservation(for: sessionID)
    await closeConnectionIfUnused(sessionID)
  }

  private func createConnection(url: URL = eventSubURL) async throws -> SessionID {
    guard !isRetired else { throw CancellationError() }
    let connection = EventSubConnection(
      network: network,
      decoder: decoder,
      eventSubURL: url,
      onMessage: receiveMessage)

    let sessionID = try await connection.resume()

    guard !isRetired else {
      await connection.cancel()
      throw CancellationError()
    }

    connections[sessionID] = connection
    return sessionID
  }

  // NOTE: needs to be async because of the keepalive timer, actor isolation gets erased
  // when passing this method as the onMessage handler to the connection.
  private func receiveMessage(
    _ result: Result<EventSubNotification, EventSubConnectionError>
  ) async {
    guard !isRetired else { return }
    switch result {
    case .success(let notification):
      // buffer events until the handler is registered
      let id = notification.subscription.id
      if let handler = eventHandlers[id] {
        handler.yield(notification.event)
      } else {
        pendingEvents[id, default: []].append(notification.event)
      }

    case .failure(let error):
      switch error {
      case .revocation(let revocation):
        let id = revocation.subscriptionID
        if let handler = eventHandlers[id] {
          handler.finish(throwing: .revocation(revocation))

          await removeHandler(for: id)
        } else {
          pendingErrors[id] = .revocation(revocation)
        }
      case .reconnectRequested(let reconnectURL, let sessionID):
        await self.reconnect(sessionID, reconnectURL: reconnectURL)
      case .disconnected(let error, let sessionID):
        await self.finishConnection(sessionID, throwing: .disconnected(with: error))
      case .timedOut(let sessionID):
        await self.finishConnection(sessionID, throwing: .timedOut)
      }
    }
  }

  private func reconnect(_ sessionID: SessionID, reconnectURL: URL) async {
    do {
      if let old = connections[sessionID] { await old.cancel() }

      let newSocketID = try await self.createConnection(url: reconnectURL)

      // move all events to the new connection
      connectionSubscriptions[newSocketID] = connectionSubscriptions[sessionID]

      if let reserved = reservedSlots.removeValue(forKey: sessionID) {
        reservedSlots[newSocketID] = reserved
      }

      connections.removeValue(forKey: sessionID)
      connectionSubscriptions.removeValue(forKey: sessionID)
    } catch {
      await finishConnection(sessionID, throwing: .disconnected(with: error))
    }
  }

  private func finishConnection(
    _ sessionID: SessionID, throwing error: EventSubError
  ) async {
    if let connection = connections[sessionID] { await connection.cancel() }

    for (socket, events) in connectionSubscriptions where socket == sessionID {
      events.forEach { event in
        if let handler = eventHandlers[event] {
          handler.finish(throwing: error)
        } else {
          pendingErrors[event] = error
        }
      }
    }

    connectionSubscriptions.removeValue(forKey: sessionID)
    connections.removeValue(forKey: sessionID)
    reservedSlots.removeValue(forKey: sessionID)
  }

  internal func reset() async {
    guard !isResetting else { return }
    isResetting = true

    defer { isResetting = false }

    await cancelConnectionCreation()

    for connection in connections.values {
      await connection.cancel()
    }

    for handler in eventHandlers.values {
      handler.finish()
    }

    connections.removeAll()
    connectionSubscriptions.removeAll()
    eventHandlers.removeAll()
    pendingEvents.removeAll()
    pendingErrors.removeAll()
    reservedSlots.removeAll()
  }

  /// Permanently rejects new setup and registration before closing the old context.
  internal func retire() async {
    isRetired = true
    await reset()
  }
}

extension EventSubClient {
  private func hasFreeCapacity(on sessionID: SessionID) -> Bool {
    let subscribedEvents = connectionSubscriptions[sessionID]?.count ?? 0
    let reserved = reservedSlots[sessionID] ?? 0
    return subscribedEvents + reserved < Self.maxSubscriptionsPerConnection
  }

  private func consumeReservation(for sessionID: SessionID) {
    guard let reserved = reservedSlots[sessionID], reserved > 0 else { return }

    let remaining = reserved - 1
    if remaining > 0 {
      reservedSlots[sessionID] = remaining
    } else {
      reservedSlots.removeValue(forKey: sessionID)
    }
  }

  private func sessionID(for subscriptionID: SubscriptionID) -> SessionID? {
    connectionSubscriptions.first(where: { $0.value.contains(subscriptionID) })?.key
  }

  private func closeConnectionIfUnused(_ sessionID: SessionID) async {
    let hasEvents = !(connectionSubscriptions[sessionID]?.isEmpty ?? true)
    let reserved = reservedSlots[sessionID] ?? 0
    guard !hasEvents, reserved == 0 else { return }

    connectionSubscriptions.removeValue(forKey: sessionID)
    if let connection = connections.removeValue(forKey: sessionID) {
      await connection.cancel()
    }
  }

  private func startConnectionCreation() {
    let id = UUID()
    let task = Task { try await createConnection() }
    connectionCreation = ConnectionCreation(id: id, task: task)

    Task { [weak self] in
      let result = await task.result
      await self?.finishConnectionCreation(id: id, with: result)
    }
  }

  private func waitForConnectionCreation() async throws -> SessionID {
    let waiterID = UUID()

    let sessionID = try await withTaskCancellationHandler {
      try await withCheckedThrowingContinuation { continuation in
        connectionCreationWaiters[waiterID] = continuation
      }
    } onCancel: {
      Task { [weak self] in
        await self?.cancelConnectionCreationWaiter(waiterID)
      }
    }

    if Task.isCancelled {
      await releaseReservation(for: sessionID)
      throw CancellationError()
    }

    return sessionID
  }

  private func cancelConnectionCreationWaiter(_ waiterID: UUID) async {
    guard let waiter = connectionCreationWaiters.removeValue(forKey: waiterID) else {
      return
    }

    if connectionCreationWaiters.isEmpty { await cancelConnectionCreation() }

    waiter.resume(throwing: CancellationError())
  }

  private func finishConnectionCreation(
    id: UUID,
    with result: Result<SessionID, Error>
  ) async {
    guard let creation = connectionCreation, creation.id == id else { return }

    connectionCreation = nil

    let waiters = Array(connectionCreationWaiters.values)
    connectionCreationWaiters.removeAll()

    switch result {
    case .success(let sessionID):
      if creation.isCancellationRequested || creation.task.isCancelled || isResetting {
        await closeConnectionIfUnused(sessionID)

        for waiter in waiters {
          waiter.resume(throwing: CancellationError())
        }
      } else {
        reservedSlots[sessionID, default: 0] += waiters.count

        for waiter in waiters {
          waiter.resume(returning: sessionID)
        }
      }
    case .failure(let error):
      let normalizedError = normalizeSetupError(error)
      for waiter in waiters {
        waiter.resume(throwing: normalizedError)
      }
    }
  }

  private func cancelConnectionCreation() async {
    guard var creation = connectionCreation else { return }

    creation.isCancellationRequested = true
    connectionCreation = creation

    creation.task.cancel()
    let result = await creation.task.result
    await finishConnectionCreation(id: creation.id, with: result)
  }

  private func normalizeSetupError(_ error: Error) -> Error {
    if error is CancellationError {
      return CancellationError()
    }

    guard let error = error as? EventSubConnectionError else {
      return EventSubError.disconnected(with: error)
    }

    if case .disconnected(let underlying, _) = error, underlying is CancellationError {
      return CancellationError()
    }

    return error.eventSubError
  }
}
