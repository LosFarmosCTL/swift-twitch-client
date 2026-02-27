internal protocol EventSubHandler {
  func yield(_ event: Event)
  func finish()
  func finish(throwing error: EventSubError)
}

internal struct EventSubCallbackHandler<T: Sendable>: EventSubHandler {
  var callback: (EventSubResult<T>) -> Void

  func yield(_ event: Event) {
    if let event = event as? T {
      callback(.event(event))
    }
  }

  func finish() { callback(.finished) }

  func finish(throwing error: EventSubError) {
    callback(.failure(error))
  }
}

internal struct EventSubContinuationHandler<T: Sendable>: EventSubHandler {
  var continuation: AsyncThrowingStream<T, any Error>.Continuation

  func yield(_ event: Event) {
    if let event = event as? T {
      continuation.yield(event)
    }
  }

  func finish() { continuation.finish() }

  func finish(throwing error: EventSubError) {
    continuation.finish(throwing: error)
  }
}

#if canImport(Combine)
  import Combine

  internal struct EventSubSubjectHandler<T: Sendable>: EventSubHandler {
    var subject: PassthroughSubject<T, EventSubError>

    func yield(_ event: Event) {
      if let event = event as? T {
        subject.send(event)
      }
    }

    func finish() { subject.send(completion: .finished) }

    func finish(throwing error: EventSubError) {
      subject.send(completion: .failure(error))
    }
  }
#endif
