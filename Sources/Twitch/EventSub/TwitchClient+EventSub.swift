import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

#if canImport(Combine)
  import Combine
#endif

extension TwitchClient {
  public func eventStream<R: Decodable & Sendable>(
    for event: EventSubSubscription<R>
  ) async throws -> AsyncThrowingStream<R, any Error> {
    do {
      let (response, socketID) = try await self.subscribe(to: event)
      let subscriptionID = response.subscription.id

      let (stream, continuation) = AsyncThrowingStream<R, any Error>.makeStream()

      continuation.onTermination = { [weak self] _ in
        Task { await self?.unsubscribe(from: subscriptionID) }
      }

      let handler = EventSubContinuationHandler(continuation: continuation)
      await self.eventSubClient.addHandler(handler, for: subscriptionID, on: socketID)

      return stream
    } catch is CancellationError {
      let (stream, continuation) = AsyncThrowingStream<R, any Error>.makeStream()
      continuation.finish()
      return stream
    }
  }

  public func eventListener<R: Decodable & Sendable>(
    on event: EventSubSubscription<R>,
    eventHandler: @escaping @Sendable (EventSubResult<R>) -> Void
  ) async throws -> TwitchCancellable {
    do {
      let (response, socketID) = try await self.subscribe(to: event)
      let subscriptionID = response.subscription.id

      let handler = EventSubCallbackHandler(callback: eventHandler)

      await self.eventSubClient.addHandler(handler, for: subscriptionID, on: socketID)

      return TwitchCancellable { [weak self] in
        Task { await self?.unsubscribe(from: subscriptionID) }
      }
    } catch is CancellationError {
      eventHandler(.finished)
      return TwitchCancellable {}
    }
  }

  #if canImport(Combine)
    public func eventPublisher<R: Decodable & Sendable>(
      for event: EventSubSubscription<R>
    ) async throws -> AnyPublisher<R, EventSubError> {
      do {
        let (response, socketID) = try await self.subscribe(to: event)
        let subscriptionID = response.subscription.id

        let subject = PassthroughSubject<R, EventSubError>()
        let handler = EventSubSubjectHandler(subject: subject)

        Task {
          await self.eventSubClient.addHandler(handler, for: subscriptionID, on: socketID)
        }

        return
          subject.handleEvents(receiveCancel: { @Sendable [weak self] in
            Task { await self?.unsubscribe(from: subscriptionID) }
          })
          .eraseToAnyPublisher()
      } catch is CancellationError {
        let subject = PassthroughSubject<R, EventSubError>()
        subject.send(completion: .finished)
        return subject.eraseToAnyPublisher()
      }
    }
  #endif

  public func resetEventSub() async {
    await self.eventSubClient.reset()
  }

  private func subscribe(
    to event: EventSubSubscription<some Decodable & Sendable>
  ) async throws
    -> (response: CreateEventSubResponse, socketID: String)
  {
    let socketID = try await self.eventSubClient.getFreeWebsocketID()

    let response = try await self.helix(
      endpoint: .createEventSubSubscription(using: .websocket(id: socketID), type: event))

    return (response, socketID)
  }

  private func unsubscribe(from subscriptionID: String) async {
    do {
      try await self.helix(endpoint: .deleteEventSubSubscription(id: subscriptionID))
    } catch {
      // ignore network errors on unsubscribe, if a simple HTTP request fails, it's
      // fair to assume that the websocket connection is already gone anyways
    }

    await self.eventSubClient.removeHandler(for: subscriptionID)
  }
}
