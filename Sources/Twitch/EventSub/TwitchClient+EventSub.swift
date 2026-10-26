import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

#if canImport(Combine)
  import Combine
#endif

extension TwitchClient {
  public func eventStream<R: Decodable & Sendable>(
    for subscription: EventSubSubscription<R>
  ) async throws -> AsyncThrowingStream<R, any Error> {
    let (response, sessionID) = try await self.subscribe(to: subscription)
    let subscriptionID = response.subscription.id

    let (stream, continuation) = AsyncThrowingStream<R, any Error>.makeStream()

    continuation.onTermination = { [weak self] _ in
      Task { await self?.unsubscribe(from: subscriptionID) }
    }

    let handler = EventSubContinuationHandler(continuation: continuation)
    await self.eventSubClient.addHandler(handler, for: subscriptionID, on: sessionID)

    return stream
  }

  public func eventListener<R: Decodable & Sendable>(
    for subscription: EventSubSubscription<R>,
    callback: @escaping @Sendable (EventSubListenerEvent<R>) -> Void
  ) async throws -> TwitchCancellable {
    let (response, sessionID) = try await self.subscribe(to: subscription)
    let subscriptionID = response.subscription.id

    let handler = EventSubCallbackHandler(callback: callback)

    await self.eventSubClient.addHandler(handler, for: subscriptionID, on: sessionID)

    return TwitchCancellable { [weak self] in
      Task { await self?.unsubscribe(from: subscriptionID) }
    }
  }

  #if canImport(Combine)
    public nonisolated func eventPublisher<R: Decodable & Sendable>(
      for subscription: EventSubSubscription<R>
    ) async throws -> AnyPublisher<R, EventSubError> {
      let (response, sessionID) = try await self.subscribe(to: subscription)
      let subscriptionID = response.subscription.id

      let subject = PassthroughSubject<R, EventSubError>()
      let handler = EventSubSubjectHandler(subject: subject)

      await self.eventSubClient.addHandler(handler, for: subscriptionID, on: sessionID)

      return
        subject.handleEvents(receiveCancel: { @Sendable [weak self] in
          Task { await self?.unsubscribe(from: subscriptionID) }
        })
        .eraseToAnyPublisher()
    }
  #endif

  public func resetEventSub() async {
    await self.eventSubClient.reset()
  }

  private func subscribe(
    to event: EventSubSubscription<some Decodable & Sendable>
  ) async throws
    -> (response: CreateEventSubSubscriptionResponse, sessionID: String)
  {
    let sessionID: String

    do {
      sessionID = try await self.eventSubClient.reserveWebSocketSessionID()
    } catch is CancellationError {
      throw CancellationError()
    } catch let error as EventSubError {
      throw error
    } catch {
      throw EventSubError.disconnected(with: error)
    }

    do {
      let response = try await self.helix(
        for: .createEventSubSubscription(
          using: .webSocket(id: sessionID), for: event))

      return (response, sessionID)
    } catch is CancellationError {
      await self.eventSubClient.releaseReservation(for: sessionID)
      throw CancellationError()
    } catch let error as HelixError {
      await self.eventSubClient.releaseReservation(for: sessionID)
      throw error
    } catch let error as EventSubError {
      await self.eventSubClient.releaseReservation(for: sessionID)
      throw error
    } catch {
      await self.eventSubClient.releaseReservation(for: sessionID)
      throw EventSubError.disconnected(with: error)
    }
  }

  private func unsubscribe(from subscriptionID: String) async {
    do {
      try await self.helix(
        for: .deleteEventSubSubscription(subscriptionID: subscriptionID))
    } catch {
      // ignore network errors on unsubscribe, if a simple HTTP request fails, it's
      // fair to assume that the webSocket connection is already gone anyways
    }

    await self.eventSubClient.removeHandler(for: subscriptionID)
  }
}
