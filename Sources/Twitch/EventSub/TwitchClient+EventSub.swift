import Foundation

#if canImport(Combine)
  import Combine
#endif

extension TwitchClient {
  /// Closes EventSub connections and clears the client's active subscriptions.
  ///
  /// Existing event consumers finish. Create new subscriptions to resume receiving
  /// events.
  public func resetEventSub() async {
    await startEventSubReset().value
  }

  /// Observes an EventSub subscription through an independent notification stream.
  ///
  /// Identical descriptions share one upstream subscription. Terminating the stream
  /// removes only this observer; the last observer schedules upstream deletion.
  /// Connection failures and revocations finish the stream with an error.
  /// The default unbounded buffer can grow when consumption is slow. Explicit bounded
  /// policies drop older (`bufferingNewest`) or incoming (`bufferingOldest`) events;
  /// they do not apply back pressure to Twitch. A retained stream is not cancelled
  /// merely by breaking out of its iteration.
  ///
  /// - Returns: A stream of typed notifications with their delivery metadata.
  /// - Throws: `TwitchAuthenticationError.userAccessTokenRequired` for app credentials,
  ///   a `HelixError` or `EventSubError` if subscription setup fails, or
  ///   `CancellationError` when setup is cancelled.
  ///
  /// - Parameters:
  ///   - subscription: The subscription details.
  ///   - bufferingPolicy: How to buffer events awaiting consumption. Defaults to unbounded.
  public func eventStream<R: Event>(
    for subscription: EventSubSubscription<R>,
    bufferingPolicy: AsyncThrowingStream<EventSubNotification<R>, any Error>.Continuation
      .BufferingPolicy = .unbounded
  ) async throws -> AsyncThrowingStream<EventSubNotification<R>, any Error> {
    let (stream, continuation) = AsyncThrowingStream<EventSubNotification<R>, any Error>.makeStream(
      bufferingPolicy: bufferingPolicy)

    let handle = try await eventListener(for: subscription) { result in
      switch result {
      case .event(let notification): continuation.yield(notification)
      case .failure(let error): continuation.finish(throwing: error)
      case .finished: continuation.finish()
      }
    }

    continuation.onTermination = { _ in handle.cancel() }
    return stream
  }

  /// Creates an EventSub subscription that delivers notifications to a callback.
  ///
  /// The callback receives typed notifications, delivery metadata, and terminal outcomes.
  /// Call the returned handle’s `cancel()` method to schedule unsubscription; releasing the handle alone
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
  public func eventListener<R: Event>(
    for subscription: EventSubSubscription<R>,
    callback: @escaping @Sendable (EventSubListenerEvent<EventSubNotification<R>>) -> Void
  ) async throws -> TwitchCancellable {
    let revision = await waitForReset()

    let registration = try await eventSubClient.observe(
      for: subscription,
      handler: EventSubCallbackHandler(callback: callback),
      revision: revision)

    return TwitchCancellable { registration.cancel() }
  }

  private func waitForReset() async -> UInt64 {
    // Capture this registration's revision before waiting. A later reset can supersede it.
    let revision = eventSubRevision
    await eventSubResetTask?.value

    return revision
  }

  #if canImport(Combine)
    /// Creates a lazy publisher of EventSub notifications.
    ///
    /// Each downstream subscriber registers independently on its first positive demand.
    /// No connection or remote subscription is created by this factory. Cancelling one
    /// downstream subscriber removes only its local registration. Matching descriptions
    /// share one upstream subscription, deleted after its last observer leaves.
    /// Events received without downstream demand are dropped, not buffered.
    ///
    /// - Returns: A publisher whose failures preserve `TwitchAuthenticationError`,
    ///   `HelixError`, `EventSubError`, or `CancellationError` from setup. Active
    ///   connection failures and revocations arrive as `EventSubError`.
    ///
    /// - Parameters:
    ///   - subscription: The subscription details.
    public nonisolated func eventPublisher<R: Event>(
      for subscription: EventSubSubscription<R>
    ) -> AnyPublisher<EventSubNotification<R>, any Error> {
      EventSubPublisher<EventSubNotification<R>> { [weak self] callback in
        guard let self else { throw CancellationError() }
        return try await self.eventListener(for: subscription, callback: callback)
      }.eraseToAnyPublisher()
    }
  #endif

  func startEventSubReset() -> Task<Void, Never> {
    eventSubRevision &+= 1

    let revision = eventSubRevision
    let previousReset = eventSubResetTask
    let reset = Task { [eventSubClient, credentials] in
      // A later reset waits for the previous sockets to finish closing.
      await previousReset?.value
      await eventSubClient.reset(using: credentials, revision: revision)
    }

    eventSubResetTask = reset
    return reset
  }
}
