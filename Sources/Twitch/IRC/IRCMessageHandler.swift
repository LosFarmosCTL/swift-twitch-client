import TwitchIRC

internal protocol IRCMessageHandler {
  func yield(_ message: IncomingMessage)
  func finish(throwing error: Error)
}

internal struct IRCMessageCallbackHandler: IRCMessageHandler {
  let callback: (Result<IncomingMessage, Error>) -> Void

  func yield(_ message: IncomingMessage) {
    callback(.success(message))
  }

  func finish(throwing error: Error) {
    callback(.failure(error))
  }
}

internal struct IRCMessageContinuationHandler: IRCMessageHandler {
  let continuation: AsyncThrowingStream<IncomingMessage, Error>.Continuation

  func yield(_ message: IncomingMessage) {
    continuation.yield(message)
  }

  func finish(throwing error: Error) {
    continuation.finish(throwing: error)
  }
}

#if canImport(Combine)
  import Combine

  internal struct IRCMessageSubjectHandler: IRCMessageHandler {
    let subject: PassthroughSubject<IncomingMessage, Error>

    func yield(_ message: IncomingMessage) {
      subject.send(message)
    }

    func finish(throwing error: Error) {
      subject.send(completion: .failure(error))
    }
  }
#endif
