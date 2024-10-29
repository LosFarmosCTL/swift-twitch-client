import Foundation
import TwitchIRC

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public actor IRCConnectionPool<WebsocketProvider: WebsocketTaskProvider> {
  typealias Connection = IRCConnection<WebsocketProvider>

  private var connections: [Connection] = []

  private let credentials: TwitchCredentials?
  private let websocketProvider: WebsocketProvider

  private var continuation: AsyncThrowingStream<IncomingMessage, Error>.Continuation?

  init(with credentials: TwitchCredentials? = nil, websocketProvider: WebsocketProvider) {
    self.credentials = credentials
    self.websocketProvider = websocketProvider
  }

  internal func connect() async throws -> AsyncThrowingStream<IncomingMessage, Error> {
    guard self.connections.isEmpty else { throw IRCError.alreadyConnected }

    let (stream, continuation) = AsyncThrowingStream<IncomingMessage, Error>.makeStream()
    self.continuation = continuation

    try await self.createConnection()

    return stream
  }

  internal func disconnect() async {
    for connection in self.connections { try? await connection.disconnect() }
    self.connections.removeAll()

    self.continuation?.finish()
  }

  internal func join(to channel: String) async throws {
    // ignore if there is already a connection to the channel
    guard await self.getConnection(to: channel) == nil else {
      return
    }

    let connection = try await self.getFreeConnection()
    try await connection.join(to: channel)
  }

  internal func part(from channel: String) async throws {
    guard let connection = await self.getConnection(to: channel) else {
      return
    }

    guard await connection.joinedChannels.count >= 2 else {
      try? await connection.disconnect()
      self.connections.removeAll(where: { $0 === connection })
      return
    }

    try await connection.part(from: channel)
  }

  private func getConnection(to channel: String) async -> Connection? {
    for connection in self.connections
    where await connection.joinedChannels.contains(channel) {
      return connection
    }

    return nil
  }

  private func getFreeConnection() async throws -> Connection {
    for connection in self.connections
    where await connection.joinedChannels.count < 90 {
      return connection
    }

    return try await self.createConnection()
  }

  @discardableResult private func createConnection() async throws -> Connection {
    let connection = Connection(credentials: credentials, websocketProvider: websocketProvider)
    let messageStream = try await connection.connect()

    Task {
      do {
        for try await message in messageStream {
          self.continuation?.yield(message)
        }
      } catch {
        self.continuation?.finish(throwing: error)
      }
    }

    connections.append(connection)
    return connection
  }
}
