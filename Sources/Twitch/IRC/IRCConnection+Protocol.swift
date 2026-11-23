import Foundation
import TwitchIRC

extension IRCConnection {
  static func handshake(
    on socket: WebSocketTask,
    credentials: TwitchCredentials?,
    timeout: Duration,
    lifetime: IRCConnectionLifetime
  ) async throws -> [IncomingMessage] {
    try await withTaskCancellationHandler {
      try await waitForHandshake(
        on: socket, credentials: credentials, timeout: timeout, lifetime: lifetime)
    } onCancel: {
      Task { await socket.cancel(with: .goingAway, reason: nil) }
    }
  }

  private static func waitForHandshake(
    on socket: WebSocketTask,
    credentials: TwitchCredentials?,
    timeout: Duration,
    lifetime: IRCConnectionLifetime
  ) async throws -> [IncomingMessage] {
    try await withThrowingTaskGroup(of: [IncomingMessage].self) { group in
      group.addTask {
        try await sendLogin(on: socket, credentials: credentials, lifetime: lifetime)
        return try await readHandshake(on: socket, authenticated: credentials != nil)
      }
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
  }

  private static let requiredCapabilities: [Capability] = [.commands, .tags]

  private static func sendLogin(
    on socket: WebSocketTask, credentials: TwitchCredentials?, lifetime: IRCConnectionLifetime
  ) async throws {
    try lifetime.check()
    await socket.resume()
    try lifetime.check()

    try await socket.send(.string(OutgoingMessage.capabilities(requiredCapabilities).serialize()))
    if let credentials {
      try await socket.send(.string(try IRCWireMessage(.pass(pass: credentials.accessToken)).text))
    }

    let login = IRCWireMessage.login(for: credentials)
    try await socket.send(.string(try IRCWireMessage(.nick(name: login)).text))
  }

  private static func readHandshake(
    on socket: WebSocketTask, authenticated: Bool
  ) async throws -> [IncomingMessage] {
    var handshake = Handshake(waitingForUserState: authenticated)

    while !handshake.isComplete {
      try Task.checkCancellation()

      for message in try await receive(on: socket) {
        try handshake.accept(message)
      }
    }

    return handshake.buffered
  }

  private struct Handshake {
    var pendingCapabilities = Set(IRCConnection.requiredCapabilities)
    var waitingForWelcome = true
    var waitingForUserState: Bool
    var buffered: [IncomingMessage] = []

    var isComplete: Bool {
      pendingCapabilities.isEmpty && !waitingForWelcome && !waitingForUserState
    }

    mutating func accept(_ message: IncomingMessage) throws {
      switch message {
      case .capabilities(let response):
        guard response.response == .acknowledged else { throw IRCError.capabilitiesRejected }
        pendingCapabilities.subtract(response.capabilities)
      case .connectionNotice:
        waitingForWelcome = false
      case .globalUserState:
        waitingForUserState = false
        buffered.append(message)
      case .reconnect:
        throw IRCError.disconnected
      default:
        buffered.append(message)
      }
    }
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
