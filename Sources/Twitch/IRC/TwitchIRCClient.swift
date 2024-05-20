import Foundation
import TwitchIRC

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

#if canImport(Combine)
  import Combine
#endif

public class TwitchIRCClient {
  private let connectionPool: IRCConnectionPool

  private var listeners: [(Result<IncomingMessage, Error>) -> Void] = []
  private var continuations: [AsyncThrowingStream<IncomingMessage, Error>.Continuation] =
    []

  #if canImport(Combine)
    private var subjects: [PassthroughSubject<IncomingMessage, Error>] = []
  #endif

  internal init(with authentication: TwitchCredentials? = nil, urlSession: URLSession)
    async throws
  {
    self.connectionPool = IRCConnectionPool(
      with: authentication,
      urlSession: urlSession
    )

    let messageStream = try await connectionPool.connect()

    Task {
      do {
        for try await message in messageStream {
          for listener in self.listeners {
            listener(.success(message))
          }

          for continuation in self.continuations {
            continuation.yield(message)
          }

          #if canImport(Combine)
            for subject in self.subjects {
              subject.send(message)
            }
          #endif
        }
      } catch {
        for listener in self.listeners {
          listener(.failure(error))
        }

        for continuation in self.continuations {
          continuation.finish(throwing: error)
        }

        #if canImport(Combine)
          for subject in self.subjects {
            subject.send(completion: .failure(error))
          }
        #endif
      }
    }
  }

  // MARK: - Async

  public func stream() -> AsyncThrowingStream<IncomingMessage, Error> {
    let (stream, continuation) = AsyncThrowingStream<IncomingMessage, Error>.makeStream()

    self.continuations.append(continuation)

    return stream
  }

  // MARK: - Callbacks

  public func listener(
    _ callback: @escaping @Sendable (Result<IncomingMessage, Error>) -> Void
  ) {
    self.listeners.append(callback)
  }

  // MARK: - Combine

  #if canImport(Combine)

    public func publisher() -> AnyPublisher<IncomingMessage, Error> {
      let subject = PassthroughSubject<IncomingMessage, Error>()

      self.subjects.append(subject)

      return PassthroughSubject().eraseToAnyPublisher()
    }

  #endif

  // MARK: - IRC

  public func join(to channel: String) async throws {
    try await self.connectionPool.join(to: channel)
  }

  public func part(from channel: String) async throws {
    try await self.connectionPool.part(from: channel)
  }
}
