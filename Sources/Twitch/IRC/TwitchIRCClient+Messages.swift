import Foundation
import TwitchIRC

extension TwitchIRCClient {
  public func messages() -> AsyncThrowingStream<IncomingMessage, Error> {
    let (stream, continuation) =
      AsyncThrowingStream<IncomingMessage, Error>.makeStream()

    if let terminalState {
      switch terminalState {
      case .finished: continuation.finish()
      case .failed(let error): continuation.finish(throwing: error)
      }

      return stream
    }

    let id = UUID()

    continuation.onTermination = { [weak self] _ in
      Task { await self?.removeHandler(withID: id) }
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
      case .finished: callback(.finished)
      case .failed(let error): callback(.failure(error))
      }

      return TwitchCancellable {}
    }

    let id = UUID()

    self.handlers.append(IRCMessageCallbackHandler(id: id, callback: callback))

    return TwitchCancellable { [weak self] in
      Task { await self?.removeHandler(withID: id) }
    }
  }
}

extension TwitchIRCClient {
  func yield(_ message: IncomingMessage) {
    guard terminalState == nil else { return }

    for handler in handlers { handler.yield(message) }
  }

  func removeHandler(withID id: UUID) {
    handlers.removeAll(where: { $0.id == id })
  }

  func finishHandlers(throwing error: Error? = nil) {
    let handlers = self.handlers
    self.handlers.removeAll()

    for handler in handlers {
      if let error {
        handler.finish(throwing: error)
      } else {
        handler.finish()
      }
    }
  }
}

#if canImport(Combine)
  @preconcurrency import Combine

  extension TwitchIRCClient {
    public nonisolated func publisher() async -> AnyPublisher<IncomingMessage, Error> {
      let subject = PassthroughSubject<IncomingMessage, Error>()
      let id = UUID()

      await self.registerPublisher(subject, withID: id)

      return subject.handleEvents(
        receiveCompletion: { [weak self] _ in
          Task { await self?.removeHandler(withID: id) }
        },
        receiveCancel: { [weak self] in
          Task { await self?.removeHandler(withID: id) }
        }
      ).eraseToAnyPublisher()
    }

    private func registerPublisher(
      _ subject: PassthroughSubject<IncomingMessage, Error>,
      withID id: UUID
    ) {
      if let terminalState {
        switch terminalState {
        case .finished: subject.send(completion: .finished)
        case .failed(let error): subject.send(completion: .failure(error))
        }

        return
      }

      handlers.append(IRCMessageSubjectHandler(id: id, subject: subject))
    }
  }
#endif
