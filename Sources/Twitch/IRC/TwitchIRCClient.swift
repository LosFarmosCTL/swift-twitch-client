import Foundation
import TwitchIRC

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public actor TwitchIRCClient {
  public enum AuthenticationStyle {
    case anonymous
    case authenticated(_ credentials: TwitchCredentials)
  }

  public struct Options {
    let enableWriteConnection: Bool

    public init(enableWriteConnection: Bool = true) {
      self.enableWriteConnection = enableWriteConnection
    }
  }

  private let writeConnection: IRCConnection?
  private let readConnectionPool: IRCConnectionPool
  private var handlers = [IRCMessageHandler]()

  public init(
    _ authenticationStyle: AuthenticationStyle,
    options: Options = .init(),
    urlSession: URLSession = URLSession(configuration: .default)
  ) async throws {
    let credentials: TwitchCredentials? =
      switch authenticationStyle {
      case .anonymous: nil
      case .authenticated(let credentials): credentials
      }

    if options.enableWriteConnection {
      self.writeConnection = IRCConnection(
        credentials: credentials,
        urlSession: urlSession
      )
    } else {
      self.writeConnection = nil
    }

    self.readConnectionPool = IRCConnectionPool(
      with: credentials,
      urlSession: urlSession
    )

    try await writeConnection?.connect()
    let messageStream = try await readConnectionPool.connect()

    Task {
      do {
        for try await message in messageStream {
          for handler in self.handlers {
            handler.yield(message)
          }
        }
      } catch {
        for handler in self.handlers {
          handler.finish(throwing: error)
        }
      }
    }
  }

  public func stream() -> AsyncThrowingStream<IncomingMessage, Error> {
    let (stream, continuation) = AsyncThrowingStream<IncomingMessage, Error>.makeStream()

    self.handlers.append(IRCMessageContinuationHandler(continuation: continuation))

    return stream
  }

  public func listener(
    _ callback: @escaping @Sendable (Result<IncomingMessage, Error>) -> Void
  ) {
    self.handlers.append(IRCMessageCallbackHandler(callback: callback))
  }

  // MARK: - IRC

  public func join(to channel: String) async throws {
    try await self.readConnectionPool.join(to: channel)
  }

  public func part(from channel: String) async throws {
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
    guard let writeConnection else {
      throw IRCError.writeConnectionNotEnabled
    }

    try await writeConnection.send(message)
  }
}

#if canImport(Combine)
  import Combine

  extension TwitchIRCClient {
    public func publisher() -> AnyPublisher<IncomingMessage, Error> {
      let subject = PassthroughSubject<IncomingMessage, Error>()

      self.handlers.append(IRCMessageSubjectHandler(subject: subject))

      return PassthroughSubject().eraseToAnyPublisher()
    }
  }
#endif
