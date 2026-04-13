import Foundation
import TwitchIRC

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

internal actor IRCConnection {
  private enum ConnectionState {
    case disconnected
    case connecting(WebSocketTask)
    case connected(WebSocketTask, Task<Void, Never>)
    case disconnecting(WebSocketTask?)
  }

  private let TMI: URL = URL(string: "wss://irc-ws.chat.twitch.tv:443")!

  private let credentials: TwitchCredentials?
  private let network: NetworkSession

  private var state: ConnectionState = .disconnected
  private(set) var joinedChannels: Set<String> = []

  var isAvailable: Bool {
    guard case .connected = state else { return false }
    guard joinedChannels.count < 90 else { return false }

    return true
  }

  init(credentials: TwitchCredentials? = nil, network: NetworkSession) {
    self.credentials = credentials
    self.network = network
  }

  deinit {
    let websocket: WebSocketTask? =
      switch state {
      case .connecting(let websocket), .connected(let websocket, _): websocket
      case .disconnecting(let websocket): websocket
      case .disconnected: nil
      }

    Task.detached { [websocket] in
      await websocket?.cancel(with: .goingAway, reason: nil)
    }
  }

  @discardableResult
  internal func connect() async throws -> AsyncThrowingStream<
    IncomingMessage, Error
  > {
    guard case .disconnected = state else { throw WebSocketError.alreadyConnected }

    let websocket = await network.webSocketTask(with: TMI)
    state = .connecting(websocket)
    await websocket.resume()

    let globalUserState: GlobalUserState?
    do {
      try await requestCapabilities()
      globalUserState = try await authenticate()
    } catch {
      await disconnect()
      throw error
    }

    let (stream, continuation) = AsyncThrowingStream.makeStream(of: IncomingMessage.self)

    let receiveTask = Task<Void, Never> { [weak self] in
      await self?.runReceiveLoop(
        on: websocket,
        continuation: continuation,
        globalUserState: globalUserState
      )
    }

    state = .connected(websocket, receiveTask)

    return stream
  }

  internal func send(_ message: OutgoingMessage) async throws {
    let websocket: WebSocketTask =
      switch state {
      case .connecting(let websocket), .connected(let websocket, _): websocket
      case .disconnecting, .disconnected: throw IRCError.disconnected
      }

    try await websocket.send(.string(message.serialize()))
  }

  internal func join(to channel: String) async throws {
    try await send(.join(to: channel))
  }

  internal func part(from channel: String) async throws {
    try await send(.part(from: channel))
  }

  internal func disconnect() async {
    joinedChannels.removeAll()

    switch state {
    case .disconnected, .disconnecting: return
    case .connecting(let websocket):
      state = .disconnecting(websocket)
      await websocket.cancel(with: .goingAway, reason: nil)
      state = .disconnected
    case .connected(let websocket, let receiveTask):
      state = .disconnecting(websocket)
      receiveTask.cancel()
      await websocket.cancel(with: .goingAway, reason: nil)
    }
  }

  private func runReceiveLoop(
    on websocket: WebSocketTask,
    continuation: AsyncThrowingStream<IncomingMessage, Error>.Continuation,
    globalUserState: GlobalUserState?
  ) async {
    if let globalUserState { continuation.yield(.globalUserState(globalUserState)) }

    do {
      while true {
        let message = try await websocket.receive()

        if case .string(let messageText) = message {
          let messages = IncomingMessage.parse(ircOutput: messageText)
            .compactMap(\.message)

          for message in messages {
            guard try await !handleMessage(message) else { continue }

            continuation.yield(message)
          }
        }
      }
    } catch {
      if case .disconnecting = state {
        continuation.finish()
      } else {
        continuation.finish(throwing: error)
        await websocket.cancel(with: .goingAway, reason: nil)
      }
    }

    joinedChannels.removeAll()
    state = .disconnected
  }

  private func requestCapabilities() async throws {
    try await send(.capabilities([.commands, .tags]))

    guard case .connecting(let websocket) = state else { throw IRCError.disconnected }

    // verify that we receive the capabilities message
    let nextMessage = try await websocket.receive()
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

  private func authenticate() async throws -> GlobalUserState? {
    if let credentials {
      // when connecting anonymously, the PASS message can be omitted
      try await send(.pass(pass: credentials.oAuth))
    }

    // twitch allows anonymous connections using justinfanXXXXX
    try await send(.nick(name: credentials?.userLogin ?? "justinfan12345"))

    guard case .connecting(let websocket) = state else { throw IRCError.disconnected }

    // verify that we receive the connection message
    let nextMessage = try await websocket.receive()
    guard case .string(let messageText) = nextMessage else {
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
      joinedChannels.insert(join.channel)
    case .part(let part):
      joinedChannels.remove(part.channel)
    default: break
    }

    return false
  }
}
