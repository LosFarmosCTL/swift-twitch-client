import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

#if canImport(Combine)
  import Combine
#endif

extension TwitchClient {
  public func eventStream<R>(for event: EventSubSubscription<R>) async throws
    -> AsyncThrowingStream<R, Error>
  {
    // TODO: handle keepalives, disconnect after not receiving messages for the specified amount of time
    _ = try await self.helix(
      endpoint: .createEventSubSubscription(using: .websocket(id: "fdsj"), type: event))

    return AsyncThrowingStream { continuation in
      let handler = EventSubContinuationHandler(continuation: continuation)

      self.eventSubClient.addHandler(handler: handler)
    }
  }

  public func eventListener<R>(
    on event: EventSubSubscription<R>,
    eventHandler: @escaping (Result<R, Error>) -> Void
  ) {
    let handler = EventSubCallbackHandler(callback: eventHandler)

    eventSubClient.addHandler(handler: handler)
  }

  #if canImport(Combine)
    public func eventPublisher<R>(for event: EventSubSubscription<R>)
      -> AnyPublisher<R, Error>
    {
      let subject = PassthroughSubject<R, Error>()
      let handler = EventSubSubjectHandler(subject: subject)

      eventSubClient.addHandler(handler: handler)

      return subject.eraseToAnyPublisher()
    }
  #endif
}
