import Foundation
import TwitchIRC

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

internal actor IRCConnection {
  private let TMI: URL = URL(string: "wss://irc-ws.chat.twitch.tv:443")!

  private let credentials: TwitchCredentials?
  private let network: NetworkSession

  private var websocket: WebSocketTask?
  private(set) var joinedChannels: Set<String> = []

  init(credentials: TwitchCredentials? = nil, network: NetworkSession) {
    self.credentials = credentials
    self.network = network
  }

  deinit {
    Task.detached { [websocket] in
      await websocket?.cancel(with: .goingAway, reason: nil)
    }
  }

  @discardableResult
  internal func connect() async throws -> AsyncThrowingStream<
    IncomingMessage, Error
  > {
    guard self.websocket == nil else { throw WebSocketError.alreadyConnected }
    self.websocket = await network.webSocketTask(with: TMI)
    await self.websocket?.resume()

    try await self.requestCapabilities()
    let globalUserState = try await self.authenticate()

    let (stream, continuation) = AsyncThrowingStream.makeStream(of: IncomingMessage.self)

    Task {
      // return global user state sent with the connection message
      if let globalUserState { continuation.yield(.globalUserState(globalUserState)) }

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
        // If we get the 'socket disconnected' error, check whether we have parted from all rooms.
        // Doing so is what causes us to get this error on the next websocket.receive() call
        let nsError = error as NSError
        if nsError.domain == "NSPOSIXErrorDomain", nsError.code == 57,
          joinedChannels.isEmpty
        {
          continuation.finish()
        } else {
          // If we can't identify the origin of the error, return it in the stream to be hanlded upstream
          continuation.finish(throwing: error)
        }

        await self.disconnect()
      }
    }

    return stream
  }

  internal func send(_ message: OutgoingMessage) async throws {
    try await self.websocket?.send(.string(message.serialize()))
  }

  internal func join(to channel: String) async throws {
    try await self.send(.join(to: channel))
  }

  internal func part(from channel: String) async throws {
    try await self.send(.part(from: channel))
  }

  internal func disconnect() async {
    await self.websocket?.cancel(with: .goingAway, reason: nil)
    self.websocket = nil

    self.joinedChannels.removeAll()
  }

  private func requestCapabilities() async throws {
    try await self.send(.capabilities([.commands, .tags]))

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

  private func authenticate() async throws -> GlobalUserState? {
    if let credentials {
      // when connecting anonymously, the PASS message can be omitted
      try await self.send(.pass(pass: credentials.oAuth))
    }

    // twitch allows anonymous connections using justinfanXXXXX
    try await self.send(.nick(name: credentials?.userLogin ?? "justinfan12345"))

    // verify that we receive the connection message
    let nextMessage = try await self.websocket?.receive()
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
