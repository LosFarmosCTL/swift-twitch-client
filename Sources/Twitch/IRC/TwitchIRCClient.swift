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

  private let connectionPool: IRCConnectionPool
  private var handlers = [IRCMessageHandler]()

  public init(
    _ authenticationStyle: AuthenticationStyle,
    urlSession: URLSession = URLSession(configuration: .default)
  ) async throws {
    let credentials: TwitchCredentials? =
      switch authenticationStyle {
      case .anonymous: nil
      case let .authenticated(credentials): credentials
      }

    self.connectionPool = IRCConnectionPool(
      with: credentials,
      urlSession: urlSession
    )
    
    let messageStream = try await connectionPool.connect()

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
    try await self.connectionPool.join(to: channel)
  }

  public func part(from channel: String) async throws {
    try await self.connectionPool.part(from: channel)
  }

  public func send(_ message: OutgoingMessage, to channel: String) async throws {
    try await self.connectionPool.send(message, to: channel)
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
