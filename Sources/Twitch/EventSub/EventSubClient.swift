import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

private typealias EventID = String
private typealias SocketID = String

internal class EventSubClient {
  private static let maxSubscriptionsPerConnection = 300

  private let credentials: TwitchCredentials
  private let urlSession: URLSession
  private let decoder: JSONDecoder

  private var connections = [SocketID: EventSubConnection]()
  private var connectionEvents = [SocketID: [EventID]]()

  private var handlers = [EventID: EventSubHandler]()

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
    handlers[eventID] = handler

    connectionEvents[socketID, default: []].append(eventID)
  }

  internal func getFreeWebsocketID() async throws -> String {
    for (socketID, events) in connectionEvents
    where events.count < Self.maxSubscriptionsPerConnection {
      return socketID
    }

    return try await createConnection()
  }

  private func createConnection() async throws -> SocketID {
    let connection = EventSubConnection(
      credentials: credentials, urlSession: urlSession, decoder: decoder)

    let socketID = try await connection.connect(completionHandler: receiveMessage)
    connections[socketID] = connection
    return socketID
  }

  private func receiveMessage(_ result: Result<EventSubNotification, EventSubError>) {
    switch result {
    case .success(let notification):
      handlers[notification.subscription.id]?.yield(notification.event)
    case .failure(let error):
      switch error {
      case .disconnected(_, let socketID):
        finishConnection(socketID, throwing: error)
      case .revocation(let revocation):
        handlers[revocation.subscriptionID]?.finish(throwing: .revocation(revocation))
      default: break
      }
    }
  }

  private func finishConnection(_ socketID: SocketID, throwing error: EventSubError) {
    for (socket, events) in connectionEvents where socket == socketID {
      events.forEach { event in
        handlers[event]?.finish(throwing: error)
      }
    }

    connections.removeValue(forKey: socketID)
  }
}
