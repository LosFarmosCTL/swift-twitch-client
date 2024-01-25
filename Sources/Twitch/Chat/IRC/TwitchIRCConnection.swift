import Foundation
import TwitchIRC

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

internal class TwitchIRCConnection {
  private let TMI: URL = URL(string: "wss://irc-ws.chat.twitch.tv:443")!

  private let authentication: IRCAuthentication
  private let websocket: WebSocket

  private var continuations: ContinuationQueue = ContinuationQueue()

  private(set) var joinedChannels: Set<String> = []

  init(with authentication: IRCAuthentication) {
    websocket = WebSocket(from: TMI)

    self.authentication = authentication
  }

  func connect(timeout: Duration?) async throws -> AsyncThrowingStream<
    IncomingMessage, Error
  > {
    let incomingMessages = try websocket.connect()

    let messageStream = AsyncThrowingStream<IncomingMessage, Error> { sink in
      Task {
        for try await messageString in incomingMessages {
          for receivedMessage in IncomingMessage.parse(ircOutput: messageString) {
            guard let message = receivedMessage.message else { continue }

            if case .ping = message {
              try await self.websocket.send(OutgoingMessage.pong.serialize())
              continue
            }

            await self.continuations.completeAny(matching: message)
            sink.yield(message)
          }
        }
      }
    }

    try await initialize(timeout: timeout)

    return messageStream
  }

  func disconnect(with statusCode: URLSessionWebSocketTask.CloseCode) {
    websocket.disconnect(with: statusCode)
  }

  func privmsg(
    to channel: String, message: String, replyingTo replyMessageId: String? = nil,
    nonce: String? = nil
  ) async throws {
    let privmsg = OutgoingMessage.privateMessage(
      to: channel, message: message, messageIdToReply: replyMessageId, clientNonce: nonce)

    try await websocket.send(privmsg.serialize())
  }

  func join(to channel: String, timeout: Duration?) async throws {
    // send a JOIN command and wait for the confirmation from twitch
    try await continuations.register(JoinContinuation(channel: channel), timeout: timeout)
    { try await self.websocket.send(OutgoingMessage.join(to: channel).serialize()) }

    joinedChannels.insert(channel)
  }

  func part(from channel: String, timeout: Duration?) async throws {
    // send a PART command and wait for the confirmation from twitch
    try await continuations.register(PartContinuation(channel: channel), timeout: timeout)
    { try await self.websocket.send(OutgoingMessage.part(from: channel).serialize()) }

    joinedChannels.remove(channel)
  }

  private func initialize(timeout: Duration?) async throws {
    // send a CAP REQ command and wait for the confirmation from twitch
    try await continuations.register(CapabilitiesContinuation(), timeout: timeout) {
      let message = OutgoingMessage.capabilities([.commands, .tags])
      try await self.websocket.send(message.serialize())

      try await self.authenticate(timeout: timeout)
    }
  }

  private func authenticate(timeout: Duration?) async throws {
    // send PASS + NICK commands and wait for the confirmation from twitch
    try await continuations.register(AuthenticationContinuation(), timeout: timeout) {
      var login: String?

      // when connecting anonymously, the PASS message can be omitted
      if case .authenticated(let username, let credentials) = self.authentication {
        login = username
        let pass = OutgoingMessage.pass(pass: credentials.oAuth)
        try await self.websocket.send(pass.serialize())
      }

      // twitch allows anonymous connections using justinfanXXXXX
      let nick = OutgoingMessage.nick(name: login ?? "justinfan12345")
      try await self.websocket.send(nick.serialize())
    }
  }
}
