import Foundation
import TwitchIRC

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

internal actor IRCConnection {
  private let TMI: URL = URL(string: "wss://irc-ws.chat.twitch.tv:443")!

  private let credentials: TwitchCredentials?
  private let urlSession: URLSession

  private var websocket: URLSessionWebSocketTask?
  private(set) var joinedChannels: Set<String> = []

  init(credentials: TwitchCredentials? = nil, urlSession: URLSession) {
    self.credentials = credentials
    self.urlSession = urlSession
  }

  deinit {
    self.websocket?.cancel(with: .goingAway, reason: nil)
  }

  internal func connect() async throws -> AsyncThrowingStream<
    IncomingMessage, Error
  > {
    guard self.websocket == nil else { throw WebSocketError.alreadyConnected }
    self.websocket = urlSession.webSocketTask(with: TMI)
    self.websocket?.resume()

    let (stream, continuation) = AsyncThrowingStream.makeStream(of: IncomingMessage.self)

    try await self.requestCapabilities()

    let globalUserState = try await self.authenticate()

    // FIXME: this does not work for some reason
    continuation.yield(.globalUserState(globalUserState))

    Task {
      do {
        while let message = try await self.websocket?.receive() {
          if case .string(let messageText) = message {
            let messages = IncomingMessage.parse(ircOutput: messageText)
              .compactMap(\.message)

            for message in messages {
              guard try await !self.handleMessage(message) else { continue }

              continuation.yield(message)
            }
          }
        }
      } catch {
        continuation.finish(throwing: error)
        self.disconnect()
      }
    }

    return stream
  }

  internal func join(to channel: String) async throws {
    let message = OutgoingMessage.join(to: channel)
    try await self.websocket?.send(.string(message.serialize()))
  }

  internal func part(from channel: String) async throws {
    let message = OutgoingMessage.part(from: channel)
    try await self.websocket?.send(.string(message.serialize()))
  }

  internal func disconnect() {
    self.websocket?.cancel(with: .goingAway, reason: nil)
    self.websocket = nil

    self.joinedChannels.removeAll()
  }

  private func requestCapabilities() async throws {
    let capReq = OutgoingMessage.capabilities([.commands, .tags])
    try await websocket?.send(.string(capReq.serialize()))

    // verify that we receive the capabilities message
    let nextMessage = try await websocket?.receive()
    guard case .string(let messageText) = nextMessage else {
      throw WebSocketError.unsupportedDataReceived
    }

    let receivedCapabilitiesMessage = IncomingMessage.parse(ircOutput: messageText)
      .map(\.message)
      .allSatisfy({ if case .capabilities = $0 { true } else { false } })

    guard receivedCapabilitiesMessage else {
      throw IRCError.loginFailed
    }
  }

  private func authenticate() async throws -> GlobalUserState {
    if let credentials {
      // when connecting anonymously, the PASS message can be omitted
      let pass = OutgoingMessage.pass(pass: credentials.oAuth)
      try await self.websocket?.send(.string(pass.serialize()))
    }

    // twitch allows anonymous connections using justinfanXXXXX
    let nick = OutgoingMessage.nick(name: credentials?.userLogin ?? "justinfan12345")
    try await self.websocket?.send(.string(nick.serialize()))

    // verify that we receive the connection message
    let nextMessage = try await self.websocket?.receive()
    guard case .string(let messageText) = nextMessage else {
      throw WebSocketError.unsupportedDataReceived
    }

    let parsedMessages = IncomingMessage.parse(ircOutput: messageText).map(\.message)

    let didReceiveConnectionMessage = parsedMessages.contains(where: {
      if case .connectionNotice = $0 { true } else { false }
    })

    guard didReceiveConnectionMessage,
      case .globalUserState(let globalUserState) = parsedMessages.last
    else {
      throw IRCError.loginFailed
    }

    return globalUserState
  }

  private func handleMessage(_ message: IncomingMessage) async throws -> Bool {
    switch message {
    case .ping:
      try await self.websocket?.send(.string(OutgoingMessage.pong.serialize()))
      return true
    case .join(let join):
      joinedChannels.insert(join.channel)
    case .part(let part):
      joinedChannels.remove(part.channel)
    default: break
    }

    return false
  }
}
