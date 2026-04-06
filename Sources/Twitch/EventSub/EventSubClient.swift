import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

private typealias EventID = String
private typealias SocketID = String

internal actor EventSubClient {
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
  private var connectionCreationTask: Task<SocketID, Error>?

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
      if let socketID = freeWebsocketID() {
        reservedSlots[socketID, default: 0] += 1
        return socketID
      }

      if let connectionCreationTask {
        do {
          _ = try await connectionCreationTask.value
        } catch {
          self.connectionCreationTask = nil
          throw error
        }

        continue
      }

      let connectionCreationTask = Task { try await createConnection() }
      self.connectionCreationTask = connectionCreationTask

      do {
        _ = try await connectionCreationTask.value
      } catch {
        self.connectionCreationTask = nil
        throw error
      }

      self.connectionCreationTask = nil
    }
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
    connectionCreationTask?.cancel()
    connectionCreationTask = nil

    isResetting = false
  }

  internal func switchCredentials(to credentials: TwitchCredentials) async {
    await reset()
    self.credentials = credentials
  }

  private func freeWebsocketID() -> SocketID? {
    connections.keys.first(where: hasFreeCapacity)
  }

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
}
