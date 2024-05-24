import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

#if canImport(Combine)
  import Combine
#endif

extension TwitchClient {
  // TODO: handle keepalives, disconnect after not receiving messages for the specified amount of time
  public func eventStream<R: Decodable>(for event: EventSubSubscription<R>) async throws
    -> AsyncThrowingStream<R, any Error>
  {
    let (response, socketID) = try await self.subscribe(to: event)

    return AsyncThrowingStream { continuation in
      let handler = EventSubContinuationHandler(continuation: continuation)
      self.eventSubClient.addHandler(handler, for: response.subscription.id, on: socketID)
    }
  }

  public func eventListener<R>(
    on event: EventSubSubscription<R>,
    eventHandler: @escaping (Result<R, EventSubError>) -> Void
  ) async throws {
    let (response, socketID) = try await self.subscribe(to: event)

    let handler = EventSubCallbackHandler(callback: eventHandler)
    self.eventSubClient.addHandler(handler, for: response.subscription.id, on: socketID)
  }

  #if canImport(Combine)
    public func eventPublisher<R>(for event: EventSubSubscription<R>) async throws
      -> AnyPublisher<R, EventSubError>
    {
      let (response, socketID) = try await self.subscribe(to: event)

      let subject = PassthroughSubject<R, EventSubError>()
      let handler = EventSubSubjectHandler(subject: subject)

      self.eventSubClient.addHandler(handler, for: response.subscription.id, on: socketID)

      return subject.eraseToAnyPublisher()
    }
  #endif

  private func subscribe(to event: EventSubSubscription<some Decodable>) async throws
    -> (response: CreateEventSubResponse, socketID: String)
  {
    let socketID = try await self.eventSubClient.getFreeWebsocketID()
    print("Received socket ID: \(socketID)")

    let response = try await self.helix(
      endpoint: .createEventSubSubscription(using: .websocket(id: socketID), type: event))

    print(response)

    return (response, socketID)
  }
}
