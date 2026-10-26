import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

#if canImport(Combine)
  import Combine
#endif

extension TwitchClient {
  /// Creates an EventSub subscription and returns its notification stream.
  ///
  /// Terminating the stream schedules removal of its subscription. Connection failures
  /// and revocations finish the stream with an error.
  ///
  /// - Returns: A stream of decoded event payloads.
  /// - Throws: A `HelixError` or `EventSubError` if subscription setup fails, or
  ///   `CancellationError` when setup is cancelled.
  ///
  /// - Parameters:
  ///   - subscription: The subscription details.
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

  /// Creates an EventSub subscription that delivers notifications to a callback.
  ///
  /// The callback receives event payloads and terminal outcomes. Call the returned
  /// handle’s `cancel()` method to schedule unsubscription; releasing the handle alone
  /// does not cancel.
  ///
  /// - Returns: An explicit cancellation handle for the subscription.
  /// - Throws: A `HelixError` or `EventSubError` if subscription setup fails, or
  ///   `CancellationError` when setup is cancelled.
  ///
  /// - Parameters:
  ///   - subscription: The subscription details.
  ///   - callback: The closure that receives decoded events or messages and terminal
  ///     outcomes. Delivery is not guaranteed to run on the main actor.
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
    /// Creates an EventSub subscription and a publisher for its notifications.
    ///
    /// Subscription setup occurs before this method returns. Cancelling a downstream
    /// subscription schedules unsubscription from Twitch.
    ///
    /// - Returns: A publisher of decoded events that fails with `EventSubError`.
    /// - Throws: A `HelixError` or `EventSubError` if setup fails, or `CancellationError`
    ///   when setup is cancelled.
    ///
    /// - Parameters:
    ///   - subscription: The subscription details.
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

  /// Closes EventSub connections and clears the client’s active subscriptions.
  ///
  /// Existing event consumers finish. Create new subscriptions to resume receiving
  /// events.
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
