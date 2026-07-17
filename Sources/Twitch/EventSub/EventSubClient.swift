import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

private typealias EventID = String
private typealias SocketID = String

internal actor EventSubClient {
  private struct ConnectionCreation {
    let id: UUID
    let task: Task<SocketID, Error>
    var isCancellationRequested = false
  }

  private static let eventSubURL = URL(string: "wss://eventsub.wss.twitch.tv/ws")!
  private static let maxSubscriptionsPerConnection = 300

  private var credentials: TwitchCredentials
  private let network: NetworkSession
  private let decoder: JSONDecoder

  private var connections = [SocketID: EventSubConnection]()
  private var connectionEvents = [SocketID: [EventID]]()
  private var eventHandlers = [EventID: EventSubHandler]()

  private var pendingEvents = [EventID: [Event]]()
  private var pendingErrors = [EventID: EventSubError]()

  private var reservedSlots = [SocketID: Int]()
  private var connectionCreation: ConnectionCreation?
  private var connectionCreationWaiters =
    [UUID: CheckedContinuation<SocketID, Error>]()

  private var isResetting = false

  internal init(
    credentials: TwitchCredentials,
    network: NetworkSession,
    decoder: JSONDecoder
  ) {
    self.credentials = credentials
    self.network = network
    self.decoder = decoder
  }

  internal func addHandler(
    _ handler: EventSubHandler, for eventID: String, on socketID: String
  ) {
    consumeReservation(for: socketID)

    eventHandlers[eventID] = handler
    connectionEvents[socketID, default: []].append(eventID)

    // if events were received before the handler was registered, yield them
    if let pendingEvents = pendingEvents.removeValue(forKey: eventID) {
      for event in pendingEvents {
        handler.yield(event)
      }
    }

    if let pendingError = pendingErrors.removeValue(forKey: eventID) {
      handler.finish(throwing: pendingError)
    }
  }

  internal func removeHandler(for eventID: String) async {
    eventHandlers.removeValue(forKey: eventID)
    pendingEvents.removeValue(forKey: eventID)
    pendingErrors.removeValue(forKey: eventID)

    if let socketID = socketID(for: eventID) {
      connectionEvents[socketID] = connectionEvents[socketID]?.filter { $0 != eventID }

      // if no more events are subscribed to the socket, close the connection
      await closeConnectionIfUnused(socketID)
    }
  }

  internal func getFreeWebsocketID() async throws -> String {
    while true {
      try Task.checkCancellation()
      guard !isResetting else { throw CancellationError() }

      let socketID = connections.keys.first(where: hasFreeCapacity)
      if let socketID {
        reservedSlots[socketID, default: 0] += 1
        return socketID
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

  internal func releaseReservation(for socketID: String) async {
    consumeReservation(for: socketID)
    await closeConnectionIfUnused(socketID)
  }

  private func createConnection(url: URL = eventSubURL) async throws -> SocketID {
    let connection = EventSubConnection(
      network: network,
      decoder: decoder,
      eventSubURL: url,
      onMessage: receiveMessage)

    let socketID = try await connection.resume()

    connections[socketID] = connection
    return socketID
  }

  // NOTE: needs to be async because of the keepalive timer, actor isolation gets erased
  // when passing this method as the onMessage handler to the connection.
  private func receiveMessage(
    _ result: Result<EventSubNotification, EventSubConnectionError>
  ) async {
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
      case .reconnectRequested(let reconnectURL, let socketID):
        await self.reconnect(socketID, reconnectURL: reconnectURL)
      case .disconnected(let error, let socketID):
        await self.finishConnection(socketID, throwing: .disconnected(with: error))
      case .timedOut(let socketID):
        await self.finishConnection(socketID, throwing: .timedOut)
      }
    }
  }

  private func reconnect(_ socketID: SocketID, reconnectURL: URL) async {
    do {
      if let old = connections[socketID] { await old.cancel() }

      let newSocketID = try await self.createConnection(url: reconnectURL)

      // move all events to the new connection
      connectionEvents[newSocketID] = connectionEvents[socketID]

      if let reserved = reservedSlots.removeValue(forKey: socketID) {
        reservedSlots[newSocketID] = reserved
      }

      connections.removeValue(forKey: socketID)
      connectionEvents.removeValue(forKey: socketID)
    } catch {
      await finishConnection(socketID, throwing: .disconnected(with: error))
    }
  }

  private func finishConnection(_ socketID: SocketID, throwing error: EventSubError) async
  {
    if let connection = connections[socketID] { await connection.cancel() }

    for (socket, events) in connectionEvents where socket == socketID {
      events.forEach { event in
        if let handler = eventHandlers[event] {
          handler.finish(throwing: error)
        } else {
          pendingErrors[event] = error
        }
      }
    }

    connectionEvents.removeValue(forKey: socketID)
    connections.removeValue(forKey: socketID)
    reservedSlots.removeValue(forKey: socketID)
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
    connectionEvents.removeAll()
    eventHandlers.removeAll()
    pendingEvents.removeAll()
    pendingErrors.removeAll()
    reservedSlots.removeAll()
  }

  internal func switchCredentials(to credentials: TwitchCredentials) async {
    await reset()
    self.credentials = credentials
  }
}

extension EventSubClient {
  private func hasFreeCapacity(on socketID: SocketID) -> Bool {
    let subscribedEvents = connectionEvents[socketID]?.count ?? 0
    let reserved = reservedSlots[socketID] ?? 0
    return subscribedEvents + reserved < Self.maxSubscriptionsPerConnection
  }

  private func consumeReservation(for socketID: SocketID) {
    guard let reserved = reservedSlots[socketID], reserved > 0 else { return }

    let remaining = reserved - 1
    if remaining > 0 {
      reservedSlots[socketID] = remaining
    } else {
      reservedSlots.removeValue(forKey: socketID)
    }
  }

  private func socketID(for eventID: EventID) -> SocketID? {
    connectionEvents.first(where: { $0.value.contains(eventID) })?.key
  }

  private func closeConnectionIfUnused(_ socketID: SocketID) async {
    let hasEvents = !(connectionEvents[socketID]?.isEmpty ?? true)
    let reserved = reservedSlots[socketID] ?? 0
    guard !hasEvents, reserved == 0 else { return }

    connectionEvents.removeValue(forKey: socketID)
    if let connection = connections.removeValue(forKey: socketID) {
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

  private func waitForConnectionCreation() async throws -> SocketID {
    let waiterID = UUID()

    let socketID = try await withTaskCancellationHandler {
      try await withCheckedThrowingContinuation { continuation in
        connectionCreationWaiters[waiterID] = continuation
      }
    } onCancel: {
      Task { [weak self] in
        await self?.cancelConnectionCreationWaiter(waiterID)
      }
    }

    if Task.isCancelled {
      await releaseReservation(for: socketID)
      throw CancellationError()
    }

    return socketID
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
    with result: Result<SocketID, Error>
  ) async {
    guard let creation = connectionCreation, creation.id == id else { return }

    connectionCreation = nil

    let waiters = Array(connectionCreationWaiters.values)
    connectionCreationWaiters.removeAll()

    switch result {
    case .success(let socketID):
      if creation.isCancellationRequested || creation.task.isCancelled || isResetting {
        await closeConnectionIfUnused(socketID)

        for waiter in waiters {
          waiter.resume(throwing: CancellationError())
        }
      } else {
        reservedSlots[socketID, default: 0] += waiters.count

        for waiter in waiters {
          waiter.resume(returning: socketID)
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
