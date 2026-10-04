import Foundation
import TwitchIRC

extension IRCConnection {
  static func handshake(
    on socket: WebSocketTask,
    credentials: TwitchCredentials?,
    timeout: Duration
  ) async throws -> [IncomingMessage] {
    try await withTaskCancellationHandler {
      try await withThrowingTaskGroup(of: [IncomingMessage].self) { group in
        group.addTask { try await performHandshake(on: socket, credentials: credentials) }

        group.addTask {
          try await Task.sleep(for: timeout)
          throw IRCError.handshakeTimedOut
        }

        defer { group.cancelAll() }

        do {
          return try await group.next() ?? []
        } catch {
          await socket.cancel(with: .goingAway, reason: nil)
          throw error
        }
      }
    } onCancel: {
      Task {
        await socket.cancel(with: .goingAway, reason: nil)
      }
    }
  }

  private static func performHandshake(
    on socket: WebSocketTask,
    credentials: TwitchCredentials?
  ) async throws -> [IncomingMessage] {
    await socket.resume()
    try Task.checkCancellation()

    try await socket.send(
      .string(OutgoingMessage.capabilities([.commands, .tags]).serialize()))

    if let credentials {
      try await socket.send(
        .string(OutgoingMessage.pass(pass: credentials.oAuth).serialize()))
    }

    let login = credentials?.userLogin.lowercased() ?? "justinfan12345"
    try await socket.send(.string(OutgoingMessage.nick(name: login).serialize()))

    var commandsAcknowledged = false
    var tagsAcknowledged = false
    var welcomeReceived = false
    var userStateReceived = credentials == nil
    var buffered: [IncomingMessage] = []

    while !(commandsAcknowledged
      && tagsAcknowledged
      && welcomeReceived
      && userStateReceived)
    {
      try Task.checkCancellation()

      for message in try await receive(on: socket) {
        switch message {
        case .capabilities(let capabilities):
          commandsAcknowledged =
            commandsAcknowledged || capabilities.capabilities.contains(.commands)
          tagsAcknowledged =
            tagsAcknowledged || capabilities.capabilities.contains(.tags)

        case .connectionNotice:
          welcomeReceived = true

        case .globalUserState:
          userStateReceived = true
          buffered.append(message)

        case .reconnect:
          throw IRCError.disconnected

        default:
          buffered.append(message)
        }
      }
    }

    return buffered
  }

  static func receive(on socket: WebSocketTask) async throws -> [IncomingMessage] {
    guard case .string(let text) = try await socket.receive() else {
      throw WebSocketError.unsupportedDataReceived
    }

    var messages: [IncomingMessage] = []

    for message in IncomingMessage.parse(ircOutput: text).compactMap(\.message) {
      if case .ping = message {
        try await socket.send(.string(OutgoingMessage.pong.serialize()))
        continue
      }

      if case .notice(let notice) = message,
        case .global(let text) = notice.kind,
        ["Login authentication failed", "Improperly formatted auth"].contains(text)
      {
        throw IRCError.loginFailed
      }

      messages.append(message)
    }

    return messages
  }
}
