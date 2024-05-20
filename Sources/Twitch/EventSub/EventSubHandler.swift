internal protocol EventSubHandler {
  func yield(_ event: Event)
  func finish(throwing error: Error)
}

internal struct EventSubCallbackHandler<T>: EventSubHandler {
  var callback: (Result<T, Error>) -> Void

  func yield(_ event: Event) {
    if let event = event as? T {
      callback(.success(event))
    }
  }

  func finish(throwing error: Error) {
    callback(.failure(error))
  }
}

internal struct EventSubContinuationHandler<T>: EventSubHandler {
  var continuation: AsyncThrowingStream<T, Error>.Continuation

  func yield(_ event: Event) {
    if let event = event as? T {
      continuation.yield(event)
    }
  }

  func finish(throwing error: Error) {
    continuation.finish(throwing: error)
  }
}

#if canImport(Combine)
  import Combine

  internal struct EventSubSubjectHandler<T>: EventSubHandler {
    var subject: PassthroughSubject<T, Error>

    func yield(_ event: Event) {
      if let event = event as? T {
        subject.send(event)
      }
    }

    func finish(throwing error: Error) {
      subject.send(completion: .failure(error))
    }
  }
#endif
