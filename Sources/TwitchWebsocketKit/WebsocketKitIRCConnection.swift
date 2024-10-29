import Foundation
import NIO
import Twitch
import TwitchIRC

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public actor WebsocketKitIRCConnection: IRCConnectionProtocol {
  private let TMI: URL = URL(string: "wss://irc-ws.chat.twitch.tv:443")!

  private let credentials: TwitchCredentials?
  private let urlSession: URLSession

  private let eventLoopGroup: EventLoopGroup
  private var websocket: AsyncWebsocket?
  private var _joinedChannels: Set<String> = []
  public var joinedChannels: Set<String> { _joinedChannels }

  public init(credentials: TwitchCredentials? = nil, urlSession: URLSession) {
    self.credentials = credentials
    self.urlSession = urlSession
    self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
  }

  deinit {
    self.websocket?.cancel(with: .goingAway)
  }

  @discardableResult
  public func connect() async throws -> AsyncThrowingStream<
    IncomingMessage, Error
  > {
    guard self.websocket == nil else { throw WebSocketError.alreadyConnected }
    self.websocket = AsyncWebsocket(url: TMI, eventLoopGroup: eventLoopGroup)
    try self.websocket?.resume()

    try await self.requestCapabilities()
    let globalUserState = try await self.authenticate()

    let (stream, continuation) = AsyncThrowingStream.makeStream(of: IncomingMessage.self)

    Task {
      // return global user state sent with the connection message
      if let globalUserState { continuation.yield(.globalUserState(globalUserState)) }

      do {
        while let messageText = try await self.websocket?.receive() {
          let messages = IncomingMessage.parse(ircOutput: messageText)
            .compactMap(\.message)

          for message in messages {
            guard try await !self.handleMessage(message) else { continue }

            continuation.yield(message)
          }
        }
      } catch {
        continuation.finish(throwing: error)
        try? await self.disconnect()
      }
    }

    return stream
  }

  public func send(_ message: OutgoingMessage) async throws {
    try await self.websocket?.send(message.serialize())
  }

  public func join(to channel: String) async throws {
    try await self.send(.join(to: channel))
  }

  public func part(from channel: String) async throws {
    try await self.send(.part(from: channel))
  }

  public func disconnect() async throws {
    self.websocket?.cancel(with: .goingAway)
    self.websocket = nil

    self._joinedChannels.removeAll()
  }

  private func requestCapabilities() async throws {
    try await self.send(.capabilities([.commands, .tags]))

    // verify that we receive the capabilities message
    let messageText = try await websocket?.receive()
    guard let messageText else {
      throw WebSocketError.unsupportedDataReceived
    }

    let receivedCapabilitiesMessage = IncomingMessage.parse(ircOutput: messageText)
      .map(\.message)
      .allSatisfy({ if case .capabilities = $0 { true } else { false } })

    guard receivedCapabilitiesMessage else {
      throw IRCError.loginFailed
    }
  }

  private func authenticate() async throws -> GlobalUserState? {
    if let credentials {
      // when connecting anonymously, the PASS message can be omitted
      try await self.send(.pass(pass: credentials.oAuth))
    }

    // twitch allows anonymous connections using justinfanXXXXX
    try await self.send(.nick(name: credentials?.userLogin ?? "justinfan12345"))

    // verify that we receive the connection message
    let messageText = try await self.websocket?.receive()
    guard let messageText else {
      throw WebSocketError.unsupportedDataReceived
    }

    let parsedMessages = IncomingMessage.parse(ircOutput: messageText).map(\.message)

    let receivedConnectionMessage = parsedMessages.contains(where: {
      if case .connectionNotice = $0 { true } else { false }
    })

    guard receivedConnectionMessage else {
      throw IRCError.loginFailed
    }

    // verify that we receive the global user state message if authenticated
    var globalUserState: GlobalUserState?
    if credentials != nil {
      guard case .globalUserState(let userState) = parsedMessages.last else {
        throw IRCError.loginFailed
      }

      globalUserState = userState
    }

    // pass on the GLOBALUSERSTATE message sent on connection
    return globalUserState
  }

  private func handleMessage(_ message: IncomingMessage) async throws -> Bool {
    switch message {
    case .ping:
      try await self.send(.pong)
      return true
    case .join(let join):
      _joinedChannels.insert(join.channel)
    case .part(let part):
      _joinedChannels.remove(part.channel)
    default: break
    }

    return false
  }
}
