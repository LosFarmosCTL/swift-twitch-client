import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

internal actor EventSubConnection {
  nonisolated let id: UUID

  enum Update: Sendable {
    case notification(EventSubNotificationFrame)
    case revocation(EventSubRevocation)
    case reconnect(URL)
    case failure(EventSubError)
  }

  private let eventSubURL: URL
  private let network: NetworkSession
  private let decoder: JSONDecoder
  private let onUpdate: @Sendable (Update) async -> Void

  private var webSocket: WebSocketTask?
  private var keepaliveTimer: KeepaliveTimer?
  private var receiveTask: Task<Void, Never>?
  private var closingTask: Task<Void, Never>?
  private var failure: EventSubError?

  init(
    id: UUID, network: NetworkSession, decoder: JSONDecoder, eventSubURL: URL,
    onUpdate: @escaping @Sendable (Update) async -> Void
  ) {
    self.id = id
    self.network = network
    self.decoder = decoder
    self.eventSubURL = eventSubURL
    self.onUpdate = onUpdate
  }

  deinit {
    receiveTask?.cancel()

    let socket = webSocket
    let timer = keepaliveTimer
    Task { await Self.closeSocket(socket, timer: timer) }
  }

  // MARK: - Handshake

  func connect() async throws -> String {
    try await withTaskCancellationHandler {
      try await performHandshake()
    } onCancel: {
      Task { [weak self] in await self?.cancel() }
    }
  }

  private func performHandshake() async throws -> String {
    do {
      let socket = try await openSocket()

      let timer = KeepaliveTimer(duration: .seconds(7)) { [weak self] in
        await self?.fail(.timedOut)
      }
      keepaliveTimer = timer

      let welcome = try await readWelcome(on: socket, timer: timer)
      await timer.reset(duration: welcome.keepaliveTimeout + .seconds(1))

      try checkOpen()
      return welcome.sessionID
    } catch {
      await cancel()

      if let failure { throw failure }
      try Task.checkCancellation()
      throw error
    }
  }

  private func openSocket() async throws -> WebSocketTask {
    try checkOpen()

    let socket = await network.webSocketTask(with: eventSubURL)
    do {
      try checkOpen()
    } catch {
      // Shutdown may have run while the network was creating the socket.
      await Self.closeSocket(socket)
      throw error
    }

    webSocket = socket
    await socket.resume()

    try checkOpen()
    return socket
  }

  private func readWelcome(
    on socket: WebSocketTask, timer: KeepaliveTimer
  ) async throws -> EventSubWelcome {
    while true {
      let frame = try await socket.receive()
      try checkOpen()
      await timer.reset()

      if case .welcome(let welcome) = decodeMessage(from: frame)?.message.payload {
        return welcome
      }
    }
  }

  // MARK: - Receiving

  /// Begin delivering frames once the session can route them.
  func startReceiving() throws {
    try checkOpen()
    guard receiveTask == nil, let socket = webSocket else { return }

    receiveTask = Task { [weak self] in
      do {
        while !Task.isCancelled {
          let frame = try await socket.receive()

          guard let self else { return }
          try await self.handleFrame(frame)
        }
      } catch {
        await self?.fail(.disconnected(with: error))
      }
    }
  }

  private func handleFrame(_ frame: URLSessionWebSocketTask.Message) async throws {
    try checkOpen()
    await keepaliveTimer?.reset()

    // Shutdown can run while the timer is being reset.
    try checkOpen()

    guard let (message, data) = decodeMessage(from: frame) else { return }
    switch message.payload {
    case .notification(let subscription):
      await onUpdate(
        .notification(
          EventSubNotificationFrame(
            subscription: subscription, messageID: message.metadata.messageID,
            sentAt: message.metadata.messageTimestamp, data: data)))
    case .revocation(let revocation):
      await onUpdate(.revocation(revocation))
    case .reconnect(let reconnect):
      await onUpdate(.reconnect(reconnect.reconnectURL))
    default: break
    }

    // Delivering an update can close the session.
    try checkOpen()
  }

  private func decodeMessage(
    from frame: URLSessionWebSocketTask.Message
  ) -> (message: EventSubMessage, data: Data)? {
    guard case .string(let text) = frame else { return nil }
    let data = Data(text.utf8)
    guard let message = try? decoder.decode(EventSubMessage.self, from: data) else { return nil }
    return (message, data)
  }

  // MARK: - Shutdown

  func cancel() async {
    await beginClosing().value
  }

  /// Close the socket and let a frame already being delivered finish before dropping its source.
  func cancelAfterDraining() async {
    await cancel()
    await receiveTask?.value
  }

  private func fail(_ error: EventSubError) async {
    guard closingTask == nil, failure == nil else { return }

    failure = error

    // During the handshake, connect() reports the failure to its caller.
    if receiveTask != nil { await onUpdate(.failure(error)) }
    await cancel()
  }

  private func beginClosing() -> Task<Void, Never> {
    if let closingTask { return closingTask }

    receiveTask?.cancel()

    let socket = webSocket
    let timer = keepaliveTimer
    webSocket = nil
    keepaliveTimer = nil

    let task = Task { await Self.closeSocket(socket, timer: timer) }
    closingTask = task
    return task
  }

  private static func closeSocket(_ socket: WebSocketTask?, timer: KeepaliveTimer? = nil) async {
    await socket?.cancel(with: .goingAway, reason: nil)
    await timer?.cancel()
  }

  private func checkOpen() throws {
    if let failure { throw failure }
    try Task.checkCancellation()
    guard closingTask == nil else { throw CancellationError() }
  }
}
