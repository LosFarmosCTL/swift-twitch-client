import Foundation
import TwitchIRC

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public actor TwitchIRCClient {
  private enum TerminalState {
    case finished
    case failed(Error)
  }

  public enum AuthenticationStyle {
    case anonymous
    case authenticated(_ credentials: TwitchCredentials)
  }

  public struct Options: Sendable {
    let enableWriteConnection: Bool

    public init(enableWriteConnection: Bool = true) {
      self.enableWriteConnection = enableWriteConnection
    }
  }

  private let writeConnection: IRCConnection?
  private let readConnectionPool: IRCConnectionPool

  private var handlers = [IRCMessageHandler]()
  private var messageTask: Task<Void, Never>?
  private var terminalState: TerminalState?

  public init(
    _ authenticationStyle: AuthenticationStyle,
    options: Options = .init(),
    urlSession: URLSession
  ) async throws {
    try await self.init(
      authenticationStyle,
      options: options,
      network: URLSessionNetworkSession(session: urlSession)
    )
  }

  internal init(
    _ authenticationStyle: AuthenticationStyle,
    options: Options = .init(),
    network: NetworkSession
  ) async throws {
    let credentials: TwitchCredentials? =
      switch authenticationStyle {
      case .anonymous: nil
      case .authenticated(let credentials): credentials
      }

    if options.enableWriteConnection {
      self.writeConnection = IRCConnection(
        credentials: credentials,
        network: network
      )
    } else {
      self.writeConnection = nil
    }

    self.readConnectionPool = IRCConnectionPool(
      with: credentials,
      network: network
    )

    try await writeConnection?.connect()
    let messageStream = try await readConnectionPool.connect()

    self.messageTask = Task { [weak self] in
      do {
        for try await message in messageStream {
          await self?.yield(message)
        }

        await self?.handleMessageStreamFinished()
      } catch {
        await self?.handleMessageStreamFailure(error)
      }
    }
  }

  deinit {
    messageTask?.cancel()

    let writeConnection = writeConnection
    let readConnectionPool = readConnectionPool

    Task.detached {
      await writeConnection?.disconnect()
      await readConnectionPool.disconnect()
    }
  }

  public func stream() -> AsyncThrowingStream<IncomingMessage, Error> {
    if let terminalState {
      let (stream, continuation) = AsyncThrowingStream<IncomingMessage, Error>
        .makeStream()

      switch terminalState {
      case .finished:
        continuation.finish()
      case .failed(let error):
        continuation.finish(throwing: error)
      }

      return stream
    }

    let id = UUID()
    let (stream, continuation) = AsyncThrowingStream<IncomingMessage, Error>.makeStream()
    continuation.onTermination = { [weak self] _ in
      Task {
        await self?.removeHandler(withID: id)
      }
    }

    self.handlers.append(
      IRCMessageContinuationHandler(id: id, continuation: continuation)
    )

    return stream
  }

  @discardableResult
  public func listener(
    _ callback: @escaping @Sendable (IRCListenerEvent) -> Void
  ) -> TwitchCancellable {
    if let terminalState {
      switch terminalState {
      case .finished:
        callback(.finished)
      case .failed(let error):
        callback(.failure(error))
      }

      return TwitchCancellable {}
    }

    let id = UUID()
    self.handlers.append(IRCMessageCallbackHandler(id: id, callback: callback))

    return TwitchCancellable { [weak self] in
      Task {
        await self?.removeHandler(withID: id)
      }
    }
  }

  public func disconnect() async {
    guard terminalState == nil else { return }

    terminalState = .finished

    messageTask?.cancel()
    messageTask = nil

    await writeConnection?.disconnect()
    await readConnectionPool.disconnect()

    finishHandlers()
  }

  // MARK: - IRC

  public func join(to channel: String) async throws {
    try throwIfDisconnected()
    try await self.readConnectionPool.join(to: channel)
  }

  public func part(from channel: String) async throws {
    try throwIfDisconnected()
    try await self.readConnectionPool.part(from: channel)
  }

  public func sendMessage(
    _ message: String,
    to channel: String,
    replyTo replyMessageID: String? = nil,
    clientNonce: String? = nil
  ) async throws {
    try await send(
      .privateMessage(
        to: channel,
        message: message,
        messageIdToReply: replyMessageID,
        clientNonce: clientNonce
      )
    )
  }

  private func send(_ message: OutgoingMessage) async throws {
    try throwIfDisconnected()

    guard let writeConnection else {
      throw IRCError.writeConnectionNotEnabled
    }

    try await writeConnection.send(message)
  }

  private func throwIfDisconnected() throws {
    if let terminalState {
      switch terminalState {
      case .finished:
        throw IRCError.disconnected
      case .failed(let error):
        throw error
      }
    }
  }

  private func yield(_ message: IncomingMessage) {
    for handler in handlers {
      handler.yield(message)
    }
  }

  private func finishHandlers() {
    let handlers = self.handlers
    self.handlers.removeAll()

    for handler in handlers {
      handler.finish()
    }
  }

  private func finishHandlers(throwing error: Error) {
    let handlers = self.handlers
    self.handlers.removeAll()

    for handler in handlers {
      handler.finish(throwing: error)
    }
  }

  private func removeHandler(withID id: UUID) {
    handlers.removeAll(where: { $0.id == id })
  }

  private func handleMessageStreamFinished() {
    messageTask = nil
  }

  private func handleMessageStreamFailure(_ error: Error) async {
    messageTask = nil

    guard terminalState == nil else {
      return
    }

    terminalState = .failed(error)

    await writeConnection?.disconnect()
    await readConnectionPool.disconnect()
    finishHandlers(throwing: error)
  }
}

#if canImport(Combine)
  @preconcurrency import Combine

  extension TwitchIRCClient {
    public nonisolated func publisher() async -> AnyPublisher<IncomingMessage, Error> {
      let subject = PassthroughSubject<IncomingMessage, Error>()
      let id = UUID()

      await self.registerPublisher(subject, withID: id)

      return
        subject
        .handleEvents(
          receiveCompletion: { [weak self] _ in
            Task {
              await self?.removeHandler(withID: id)
            }
          },
          receiveCancel: { [weak self] in
            Task {
              await self?.removeHandler(withID: id)
            }
          }
        )
        .eraseToAnyPublisher()
    }

    private func registerPublisher(
      _ subject: PassthroughSubject<IncomingMessage, Error>,
      withID id: UUID
    ) {
      if let terminalState {
        switch terminalState {
        case .finished:
          subject.send(completion: .finished)
        case .failed(let error):
          subject.send(completion: .failure(error))
        }

        return
      }

      handlers.append(IRCMessageSubjectHandler(id: id, subject: subject))
    }
  }
#endif
