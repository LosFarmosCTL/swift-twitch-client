import Foundation
import TwitchIRC

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

internal actor IRCConnectionPool {
  private var connections: [IRCConnection] = []
  private var relayTasks: [ObjectIdentifier: Task<Void, Never>] = [:]

  private let credentials: TwitchCredentials?
  private let network: NetworkSession

  private var continuation: AsyncThrowingStream<IncomingMessage, Error>.Continuation?
  private var isDisconnecting = false

  init(with credentials: TwitchCredentials? = nil, network: NetworkSession) {
    self.credentials = credentials
    self.network = network
  }

  internal func connect() async throws -> AsyncThrowingStream<IncomingMessage, Error> {
    guard self.connections.isEmpty else { throw IRCError.alreadyConnected }

    self.isDisconnecting = false

    let (stream, continuation) = AsyncThrowingStream<IncomingMessage, Error>.makeStream()
    self.continuation = continuation

    try await self.createConnection()

    return stream
  }

  internal func disconnect() async {
    self.isDisconnecting = true

    for connection in self.connections { await connection.disconnect() }

    for relayTask in self.relayTasks.values {
      relayTask.cancel()
    }

    self.connections.removeAll()
    self.relayTasks.removeAll()

    self.continuation?.finish()
    self.continuation = nil
    self.isDisconnecting = false
  }

  internal func join(to channel: String) async throws {
    // ignore if there is already a connection to the channel
    guard await self.getConnection(to: channel) == nil else {
      return
    }

    let connection = try await self.getAvailableConnection()
    try await connection.join(to: channel)
  }

  internal func part(from channel: String) async throws {
    guard let connection = await self.getConnection(to: channel) else {
      return
    }

    guard await connection.joinedChannels.count >= 2 else {
      await connection.disconnect()
      self.connections.removeAll(where: { $0 === connection })
      return
    }

    try await connection.part(from: channel)
  }

  private func getConnection(to channel: String) async -> IRCConnection? {
    for connection in self.connections
    where await connection.joinedChannels.contains(channel) {
      return connection
    }

    return nil
  }

  private func getAvailableConnection() async throws -> IRCConnection {
    for connection in self.connections where await connection.isAvailable {
      return connection
    }

    return try await self.createConnection()
  }

  @discardableResult private func createConnection() async throws -> IRCConnection {
    let connection = IRCConnection(credentials: credentials, network: network)
    let messageStream = try await connection.connect()
    let identifier = ObjectIdentifier(connection)

    connections.append(connection)

    relayTasks[identifier] = Task { [weak self] in
      do {
        for try await message in messageStream {
          await self?.yield(message)
        }

        await self?.finishConnectionRelay(for: connection)
      } catch {
        await self?.finishConnectionRelay(for: connection, error: error)
      }
    }

    return connection
  }

  private func yield(_ message: IncomingMessage) {
    continuation?.yield(message)
  }

  private func finish(throwing error: Error) {
    continuation?.finish(throwing: error)
    continuation = nil
  }

  private func removeConnection(_ connection: IRCConnection) {
    connections.removeAll(where: { $0 === connection })
  }

  private func finishConnectionRelay(
    for connection: IRCConnection,
    error: Error? = nil
  ) {
    let identifier = ObjectIdentifier(connection)
    relayTasks.removeValue(forKey: identifier)
    removeConnection(connection)

    guard !isDisconnecting, let error else {
      return
    }

    finish(throwing: error)
  }
}
