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
  /// - Throws: `TwitchAuthenticationError.userAccessTokenRequired` for app credentials,
  ///   a `HelixError` or `EventSubError` if subscription setup fails, or
  ///   `CancellationError` when setup is cancelled.
  ///
  /// - Parameters:
  ///   - subscription: The subscription details.
  public func eventStream<R: Decodable & Sendable>(
    for subscription: EventSubSubscription<R>
  ) async throws -> AsyncThrowingStream<R, any Error> {
    let (stream, continuation) = AsyncThrowingStream<R, any Error>.makeStream()
    let handler = EventSubContinuationHandler(continuation: continuation)
    let registration: EventSubRegistration

    do {
      registration = try await subscribe(to: subscription, handler: handler)
    } catch {
      continuation.finish(throwing: error)
      throw error
    }

    continuation.onTermination = { [weak self] _ in
      Task { await self?.unsubscribe(registration) }
    }

    return stream
  }

  /// Creates an EventSub subscription that delivers notifications to a callback.
  ///
  /// The callback receives event payloads and terminal outcomes. Call the returned
  /// handle’s `cancel()` method to schedule unsubscription; releasing the handle alone
  /// does not cancel.
  ///
  /// - Returns: An explicit cancellation handle for the subscription.
  /// - Throws: `TwitchAuthenticationError.userAccessTokenRequired` for app credentials,
  ///   a `HelixError` or `EventSubError` if subscription setup fails, or
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
    let handler = EventSubCallbackHandler(callback: callback)
    let registration = try await subscribe(to: subscription, handler: handler)

    return TwitchCancellable { [weak self] in
      Task { await self?.unsubscribe(registration) }
    }
  }

  #if canImport(Combine)
    /// Creates an EventSub subscription and a publisher for its notifications.
    ///
    /// Subscription setup occurs before this method returns. Cancelling a downstream
    /// subscription schedules unsubscription from Twitch.
    ///
    /// - Returns: A publisher of decoded events that fails with `EventSubError`.
    /// - Throws: `TwitchAuthenticationError.userAccessTokenRequired` for app credentials,
    ///   a `HelixError` or `EventSubError` if setup fails, or `CancellationError`
    ///   when setup is cancelled.
    ///
    /// - Parameters:
    ///   - subscription: The subscription details.
    public nonisolated func eventPublisher<R: Decodable & Sendable>(
      for subscription: EventSubSubscription<R>
    ) async throws -> AnyPublisher<R, EventSubError> {
      let subject = PassthroughSubject<R, EventSubError>()
      let handler = EventSubSubjectHandler(subject: subject)
      let registration = try await subscribe(to: subscription, handler: handler)

      return
        subject.handleEvents(receiveCancel: { @Sendable [weak self] in
          Task { await self?.unsubscribe(registration) }
        })
        .eraseToAnyPublisher()
    }
  #endif

  /// Closes EventSub connections and clears the client’s active subscriptions.
  ///
  /// Existing event consumers finish. Create new subscriptions to resume receiving
  /// events.
  public func resetEventSub() async {
    let previous = eventSubClient
    eventSubClient = EventSubClient(network: network, decoder: decoder)
    await previous.retire()
  }

  private struct EventSubRegistration: Sendable {
    let subscriptionID: String
    // A handler owns its stream termination closure; do not retain its owning client.
    weak var client: EventSubClient?
    let credentials: TwitchCredentials
  }

  private func subscribe(
    to event: EventSubSubscription<some Decodable & Sendable>,
    handler: EventSubHandler
  ) async throws -> EventSubRegistration {
    let credentials = self.credentials
    _ = try credentials.requireUser()
    let client = eventSubClient
    let sessionID: String

    do {
      sessionID = try await client.reserveWebSocketSessionID()
    } catch is CancellationError {
      throw CancellationError()
    } catch let error as EventSubError {
      throw error
    } catch {
      throw EventSubError.disconnected(with: error)
    }

    var registration: EventSubRegistration?
    do {
      try Task.checkCancellation()
      guard eventSubClient === client else { throw CancellationError() }

      let response = try await Self.helix(
        for: .createEventSubSubscription(using: .webSocket(id: sessionID), for: event),
        credentials: credentials, network: network, encoder: encoder, decoder: decoder)
      let created = EventSubRegistration(
        subscriptionID: response.subscription.id, client: client, credentials: credentials
      )
      registration = created

      try Task.checkCancellation()
      guard eventSubClient === client else { throw CancellationError() }

      let added = await client.addHandler(
        handler, for: created.subscriptionID, on: sessionID)
      guard added, eventSubClient === client else { throw CancellationError() }

      try Task.checkCancellation()
      return created
    } catch {
      if let registration { await unsubscribe(registration) }
      await client.releaseReservation(for: sessionID)
      throw subscriptionSetupError(error)
    }
  }

  private func subscriptionSetupError(_ error: any Error) -> any Error {
    switch error {
    case is CancellationError: CancellationError()
    case let error as HelixError: error
    case let error as EventSubError: error
    default: EventSubError.disconnected(with: error)
    }
  }

  private func unsubscribe(_ registration: EventSubRegistration) async {
    // Cleanup belongs to the original credential and connection context, even after
    // the parent client has switched to another account or to an app token.
    try? await Self.helix(
      for: .deleteEventSubSubscription(subscriptionID: registration.subscriptionID),
      credentials: registration.credentials, network: network, encoder: encoder,
      decoder: decoder)
    await registration.client?.removeHandler(for: registration.subscriptionID)
  }
}
