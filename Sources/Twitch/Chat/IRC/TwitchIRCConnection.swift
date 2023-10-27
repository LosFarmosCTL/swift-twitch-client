import Foundation
import TwitchIRC

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

internal class TwitchIRCConnection {
  private let TMI: URL = URL(string: "wss://irc-ws.chat.twitch.tv:443")!

  private let authentication: IRCAuthentication
  private let websocket: WebSocket

  private var continuations: [TwitchContinuation] = []

  private(set) var joinedChannels: Set<String> = []

  init(with authentication: IRCAuthentication) {
    websocket = WebSocket(from: TMI)

    self.authentication = authentication
  }

  internal func connect() async throws -> AsyncThrowingStream<
    IncomingMessage, Error
  > {
    let incomingMessages = try websocket.connect()

    let messageStream = AsyncThrowingStream<IncomingMessage, Error> {
      continuation in
      Task {
        for try await messageString in incomingMessages {
          for receivedMessage in IncomingMessage.parse(ircOutput: messageString)
          {
            guard let message = receivedMessage.message else { continue }

            if case .ping = message {
              try await self.websocket.send(OutgoingMessage.pong.serialize())
              continue
            }

            await self.checkContinuations(with: message)
            continuation.yield(message)
          }
        }
      }
    }

    try await requestCapabilities()
    try await authenticate()

    return messageStream
  }

  internal func disconnect(with statusCode: URLSessionWebSocketTask.CloseCode) {
    websocket.disconnect(with: statusCode)
  }

  internal func privmsg(
    to channel: String, message: String,
    replyingTo replyMessageId: String? = nil, nonce: String? = nil
  ) async throws {
    let privmsg = OutgoingMessage.privateMessage(
      to: channel, message: message, messageIdToReply: replyMessageId,
      clientNonce: nonce)

    try await websocket.send(privmsg.serialize())
  }

  internal func join(to channel: String) async throws {
    try await withCheckedThrowingContinuation { continuation in
      continuations.append(JoinContinuation(continuation, channel: channel))

      Task {
        try await websocket.send(OutgoingMessage.join(to: channel).serialize())
      }
    }

    joinedChannels.insert(channel)
  }

  internal func part(from channel: String) async throws {
    try await withCheckedThrowingContinuation { continuation in
      continuations.append(PartContinuation(continuation, channel: channel))

      Task {
        try await websocket.send(
          OutgoingMessage.part(from: channel).serialize())
      }
    }

    joinedChannels.remove(channel)
  }

  private func requestCapabilities() async throws {
    try await withCheckedThrowingContinuation { continuation in
      continuations.append(CapabilitiesContinuation(continuation))

      Task {
        let message = OutgoingMessage.capabilities([.commands, .tags])
        try await websocket.send(message.serialize())
      }
    }
  }

  private func authenticate() async throws {
    try await withCheckedThrowingContinuation { continuation in
      continuations.append(AuthenticationContinuation(continuation))

      Task {
        var login: String?

        // when connecting anonymously, the PASS message can be omitted
        if case .authenticated(let username, let credentials) = authentication {
          login = username
          let pass = OutgoingMessage.pass(pass: credentials.oAuth)
          try await websocket.send(pass.serialize())
        }

        let nick = OutgoingMessage.nick(name: login ?? "justinfan12345")
        try await websocket.send(nick.serialize())
      }
    }
  }

  // TODO: check all other NOTICE cases that indicate failure
  private func checkContinuations(with message: IncomingMessage) async {
    for continuation in continuations {
      await continuation.check(message: message)
    }
  }
}
