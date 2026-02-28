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

    if let socketID = connectionEvents.keys.first(where: { $0.contains(eventID) }) {
      connectionEvents[socketID] = connectionEvents[socketID]?.filter { $0 != eventID }

      // if no more events are subscribed to the socket, close the connection
      if connectionEvents[socketID]?.isEmpty == true {
        connectionEvents.removeValue(forKey: socketID)
        if let connection = connections.removeValue(forKey: socketID) {
          await connection.cancel()
        }
      }
    }
  }

  internal func getFreeWebsocketID() async throws -> String {
    for (socketID, events) in connectionEvents
    where events.count < Self.maxSubscriptionsPerConnection {
      return socketID
    }

    return try await createConnection()
  }

  private func createConnection(url: URL = eventSubURL) async throws -> SocketID {
    let connection = EventSubConnection(
      credentials: credentials,
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

    isResetting = false
  }

  internal func switchCredentials(to credentials: TwitchCredentials) async {
    await reset()
    self.credentials = credentials
  }
}
