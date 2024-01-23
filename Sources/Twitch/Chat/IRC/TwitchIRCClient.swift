import Foundation
import TwitchIRC

internal class TwitchIRCClient {
  private let options: ChatClientOptions

  private var writeConnection: TwitchIRCConnection
  private var readConnections: [TwitchIRCConnection]

  private let authentication: IRCAuthentication

  private var messageSink:
    AsyncThrowingStream<IncomingMessage, Error>.Continuation?

  init(with authentication: IRCAuthentication, options: ChatClientOptions) {
    self.options = options

    self.authentication = authentication

    self.writeConnection = TwitchIRCConnection(with: authentication)

    let initialReadConnection = TwitchIRCConnection(with: authentication)
    self.readConnections = [initialReadConnection]
  }

  internal func connect() async throws -> AsyncThrowingStream<
    IncomingMessage, Error
  > {
    try await connectWriteConnection(self.writeConnection)

    for connection in self.readConnections {
      try await connectReadConnection(connection)
    }

    return AsyncThrowingStream<IncomingMessage, Error> { continuation in
      self.messageSink = continuation
    }
  }

  internal func disconnect() {
    self.writeConnection.disconnect(with: .normalClosure)

    for connection in self.readConnections {
      connection.disconnect(with: .normalClosure)
    }

    self.messageSink?.finish()
  }

  internal func join(to channel: String) async throws {
    if self.readConnections.first(where: { $0.joinedChannels.contains(channel) }
    ) != nil {
      return
    } else if let freeConnection = self.readConnections.first(where: {
      $0.joinedChannels.count < 90
    }) {
      try await freeConnection.join(to: channel, timeout: options.joinTimeout)
    } else {
      let newConnection = self.addConnection()
      try await connectReadConnection(newConnection)

      try await newConnection.join(to: channel, timeout: options.joinTimeout)
    }
  }

  internal func part(from channel: String) async throws {
    if let connection = self.readConnections.first(where: {
      $0.joinedChannels.contains(channel)
    }) {
      try await connection.part(from: channel, timeout: options.partTimeout)

      if connection.joinedChannels.count == 0 {
        connection.disconnect(with: .goingAway)
        self.readConnections.removeAll(where: { $0 === connection })
      }
    }
  }

  internal func send(
    _ message: String, in channel: String, replyingTo replyMsgId: String?,
    nonce: String?
  ) async throws {
    try await self.writeConnection.privmsg(
      to: channel, message: message, replyingTo: replyMsgId, nonce: nonce)
  }

  private func addConnection() -> TwitchIRCConnection {
    let newConnection = TwitchIRCConnection(with: self.authentication)
    self.readConnections.append(newConnection)

    return newConnection
  }

  private func connectReadConnection(_ connection: TwitchIRCConnection)
    async throws
  {
    let messages = try await connection.connect(timeout: options.connectTimeout)

    Task {
      for try await message in messages {
        switch message {
        case .clearChat, .userNotice, .clearMessage, .roomState, .userState,
          .globalUserState, .privateMessage:
          messageSink?.yield(message)
        default: break
        }
      }
    }
  }

  private func connectWriteConnection(_ connection: TwitchIRCConnection)
    async throws
  {
    let messages = try await connection.connect(timeout: options.connectTimeout)

    Task {
      for try await message in messages {
        switch message {
        case .userState, .notice: messageSink?.yield(message)
        default: break
        }
      }
    }
  }
}
