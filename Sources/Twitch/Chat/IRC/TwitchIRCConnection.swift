import Foundation
import TwitchIRC

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

internal class TwitchIRCConnection {
  private let TMI: URL = URL(string: "wss://irc-ws.chat.twitch.tv:443")!

  private let authentication: IRCAuthentication
  private let websocket: WebSocket

  internal var joinedChannels: [String] = []  // TODO: IMPLEMENT THIS!!!

  init(with authentication: IRCAuthentication) {
    websocket = WebSocket(from: TMI)

    self.authentication = authentication

    joinContinuations = [:]
    partContinuations = [:]
  }

  internal func connect() async throws -> AsyncThrowingStream<
    IncomingMessage, Error
  > {
    let incomingMessages = try websocket.connect()

    try await requestCapabilities()
    try await authenticate()

    return AsyncThrowingStream<IncomingMessage, Error> { continuation in
      Task {
        for try await messageString in incomingMessages {
          for receivedMessage in IncomingMessage.parse(ircOutput: messageString)
          {
            guard let message = receivedMessage.message else { continue }

            if case .ping = message {
              try await self.websocket.send(OutgoingMessage.pong.serialize())
              continue
            }

            checkContinuations(message: message)
            continuation.yield(message)
          }
        }
      }
    }
  }

  internal func disconnect(with statusCode: URLSessionWebSocketTask.CloseCode) {
    websocket.disconnect(with: statusCode)
  }

  internal func privmsg(
    to channel: String, message: String, with tags: [String: String]? = nil
  ) async throws {
    try await self.privmsg(
      to: channel, message: message, replyingTo: tags?[""],
      nonce: tags?["client-nonce"])
  }

  internal func privmsg(
    to channel: String, message: String,
    replyingTo replyMessageId: String? = nil, nonce: String? = nil
  ) async throws {
    try await websocket.send(
      OutgoingMessage.privateMessage(
        to: channel, message: message, messageIdToReply: replyMessageId,
        clientNonce: nonce
      ).serialize())
  }

  private var joinContinuations: [String: CheckedContinuation<Void, Error>]
  internal func join(to channel: String) async throws {
    let timeout = Task {
      try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
      throw TimeoutError()
    }

    defer {
      self.joinContinuations[channel] = nil
      timeout.cancel()
    }

    try await withCheckedThrowingContinuation { continuation in
      self.joinContinuations[channel] = continuation

      Task {
        try await websocket.send(OutgoingMessage.join(to: channel).serialize())

        do { try await timeout.value } catch is TimeoutError {
          continuation.resume(throwing: TimeoutError())
        }
      }
    }

    joinedChannels.append(channel)
  }

  private var partContinuations: [String: CheckedContinuation<Void, Error>]
  internal func part(from channel: String) async throws {
    let timeout = Task {
      try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
      throw TimeoutError()
    }

    defer {
      self.partContinuations[channel] = nil
      timeout.cancel()
    }

    try await withCheckedThrowingContinuation { continuation in
      self.partContinuations[channel] = continuation

      Task {
        try await websocket.send(
          OutgoingMessage.part(from: channel).serialize())

        do { try await timeout.value } catch is TimeoutError {
          continuation.resume(throwing: TimeoutError())
        }
      }
    }

    joinedChannels.removeAll(where: { $0 == channel })
  }

  private struct TimeoutError: Error {
    var errorDescription: String? = "Task timed out before completion"
  }

  private var capabilityContinuation: CheckedContinuation<Void, Error>?
  private func requestCapabilities() async throws {
    let timeout = Task {
      try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
      throw TimeoutError()
    }

    defer {
      self.capabilityContinuation = nil
      timeout.cancel()
    }

    try await withCheckedThrowingContinuation { continuation in
      self.capabilityContinuation = continuation

      Task {
        try await websocket.send(
          OutgoingMessage.capabilities([.commands, .tags]).serialize())

        do { try await timeout.value } catch is TimeoutError {
          continuation.resume(throwing: TimeoutError())
        }
      }
    }
  }

  private var authenticationContinuation: CheckedContinuation<Void, Error>?
  private func authenticate() async throws {
    let timeout = Task {
      try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
      throw TimeoutError()
    }

    defer {
      self.authenticationContinuation = nil
      timeout.cancel()
    }

    try await withCheckedThrowingContinuation { continuation in
      self.authenticationContinuation = continuation

      Task {
        var login: String?
        switch authentication {
        case .authenticated(let loginName, let credentials):
          login = loginName
          try await websocket.send(
            OutgoingMessage.pass(pass: credentials.oAuth).serialize())
          fallthrough
        case .anonymous:
          try await websocket.send(
            OutgoingMessage.nick(name: login ?? "justinfan12345").serialize())
        }

        do { try await timeout.value } catch is TimeoutError {
          continuation.resume(throwing: TimeoutError())
        }
      }
    }
  }

  // TODO: check all other NOTICE cases that indicate failure
  // TODO: verify that we are not resuming multiple times (i.e. connection notice)
  // swiftlint:disable:next cyclomatic_complexity
  private func checkContinuations(message: IncomingMessage) {
    switch message {
    case .join(let joinMessage):
      if let continuation = joinContinuations[joinMessage.channel] {
        continuation.resume()
      }
    case .part(let partMessage):
      if let continuation = partContinuations[partMessage.channel] {
        continuation.resume()
      }
    case .capabilities: capabilityContinuation?.resume()
    case .connectionNotice: authenticationContinuation?.resume()
    case .notice(let notice):
      switch notice.kind {
      case .global(let message):
        if message.lowercased().starts(with: "login auth") {
          authenticationContinuation?.resume(throwing: IRCError.loginFailed)
        }
      case .local(let channel, let message, let noticeId):
        switch noticeId {
        case .msgChannelSuspended:
          if let continuation = joinContinuations[channel] {
            continuation.resume(throwing: IRCError.channelSuspended(channel))
          }
        case .msgBanned:
          if let continuation = joinContinuations[channel] {
            continuation.resume(throwing: IRCError.bannedFromChannel(channel))
          }
        default: break
        }
      default: break
      }
    default: break
    }
  }
}
