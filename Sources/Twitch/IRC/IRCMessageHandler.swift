import Foundation
import TwitchIRC

public enum IRCListenerEvent: Sendable {
  case message(IncomingMessage)
  case finished
  case failure(Error)
}

internal protocol IRCMessageHandler {
  var id: UUID { get }
  func yield(_ message: IncomingMessage)
  func finish()
  func finish(throwing error: Error)
}

internal struct IRCMessageCallbackHandler: IRCMessageHandler {
  let id: UUID
  let callback: (IRCListenerEvent) -> Void

  func yield(_ message: IncomingMessage) {
    callback(.message(message))
  }

  func finish() {
    callback(.finished)
  }

  func finish(throwing error: Error) {
    callback(.failure(error))
  }
}

internal struct IRCMessageContinuationHandler: IRCMessageHandler {
  let id: UUID
  let continuation: AsyncThrowingStream<IncomingMessage, Error>.Continuation

  func yield(_ message: IncomingMessage) {
    continuation.yield(message)
  }

  func finish() {
    continuation.finish()
  }

  func finish(throwing error: Error) {
    continuation.finish(throwing: error)
  }
}

#if canImport(Combine)
  @preconcurrency import Combine

  internal final class IRCMessageSubjectHandler: IRCMessageHandler, @unchecked Sendable {
    let id: UUID
    let subject: PassthroughSubject<IncomingMessage, Error>

    init(id: UUID, subject: PassthroughSubject<IncomingMessage, Error>) {
      self.id = id
      self.subject = subject
    }

    func yield(_ message: IncomingMessage) {
      subject.send(message)
    }

    func finish() {
      subject.send(completion: .finished)
    }

    func finish(throwing error: Error) {
      subject.send(completion: .failure(error))
    }
  }
#endif
