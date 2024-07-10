import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

private typealias EventID = String
private typealias SocketID = String

internal class EventSubClient {
  private static let eventSubURL = URL(string: "wss://eventsub.wss.twitch.tv/ws")!
  private static let maxSubscriptionsPerConnection = 300

  private let credentials: TwitchCredentials
  private let urlSession: URLSession
  private let decoder: JSONDecoder

  private var connections = [SocketID: EventSubConnection]()
  private var connectionEvents = [SocketID: [EventID]]()
  private var eventHandlers = [EventID: EventSubHandler]()

  internal init(
    credentials: TwitchCredentials, urlSession: URLSession, decoder: JSONDecoder
  ) {
    self.credentials = credentials
    self.urlSession = urlSession
    self.decoder = decoder
  }

  internal func addHandler(
    _ handler: EventSubHandler, for eventID: String, on socketID: String
  ) {
    eventHandlers[eventID] = handler

    connectionEvents[socketID, default: []].append(eventID)
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
      credentials: credentials, urlSession: urlSession, decoder: decoder,
      eventSubURL: url, onMessage: receiveMessage(_:))

    let socketID = try await connection.resume()

    connections[socketID] = connection
    return socketID
  }

  private func receiveMessage(
    _ result: Result<EventSubNotification, EventSubConnectionError>
  ) {
    switch result {
    case .success(let notification):
      eventHandlers[notification.subscription.id]?.yield(notification.event)

    case .failure(let error):
      switch error {
      case .revocation(let revocation):
        eventHandlers[revocation.subscriptionID]?.finish(
          throwing: .revocation(revocation))
      case .reconnectRequested(let reconnectURL, let socketID):
        self.reconnect(socketID, reconnectURL: reconnectURL)
      case .disconnected(let error, let socketID):
        finishConnection(socketID, throwing: .disconnected(with: error))
      case .timedOut(let socketID):
        finishConnection(socketID, throwing: .timedOut)
      }
    }
  }

  private func reconnect(_ socketID: SocketID, reconnectURL: URL) {
    Task {
      do {
        let newSocketID = try await self.createConnection()

        // move all events to the new connection
        connectionEvents[newSocketID] = connectionEvents[socketID]

        connections.removeValue(forKey: socketID)
        connectionEvents.removeValue(forKey: socketID)
      } catch {
        finishConnection(socketID, throwing: .disconnected(with: error))
      }
    }
  }

  private func finishConnection(_ socketID: SocketID, throwing error: EventSubError) {
    for (socket, events) in connectionEvents where socket == socketID {
      events.forEach { event in
        eventHandlers[event]?.finish(throwing: error)
      }
    }

    connectionEvents.removeValue(forKey: socketID)
    connections.removeValue(forKey: socketID)
  }
}
