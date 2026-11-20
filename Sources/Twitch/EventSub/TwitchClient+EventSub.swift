import Foundation

#if canImport(Combine)
  import Combine
#endif

extension TwitchClient {
  /// Closes all EventSub WebSocket sessions and clears active subscriptions.
  ///
  /// Existing streams, callbacks, and Combine publishers finish normally. Calling this
  /// method does not affect Helix or managed chat IRC connections, though an EventSub
  /// chat reader will see its subscriptions end. Start new subscriptions to resume
  /// receiving EventSub notifications.
  ///
  /// - SeeAlso: <doc:EventSub>, ``switchCredentials(to:chatBehavior:)``
  public func resetEventSub() async {
    await startEventSubReset().value
  }

  /// Observes an EventSub subscription through an independent async throwing stream.
  ///
  /// Matching subscription descriptions (same account, type, version, and condition)
  /// share a single upstream Twitch subscription. Terminating this stream removes only
  /// your local observer; the client schedules upstream subscription deletion once the
  /// last observer leaves.
  ///
  /// Connection failures and subscription revocations finish the stream by throwing an
  /// ``EventSubError``. Calling ``resetEventSub()`` or
  /// ``switchCredentials(to:chatBehavior:)`` finishes the stream normally.
  ///
  /// - Important: The default `.unbounded` policy can grow without limit if consumption
  ///   falls behind. Explicit bounded policies drop older (`.bufferingNewest`) or newer
  ///   (`.bufferingOldest`) notifications without applying back pressure to Twitch. Simply
  ///   breaking out of a `for try await` loop while retaining the stream does not cancel
  ///   its registration—cancel the consuming task or let the stream deallocate.
  /// - Parameters:
  ///   - subscription: A typed ``EventSubSubscription`` describing the topic and condition.
  ///   - bufferingPolicy: How to buffer notifications awaiting consumption. Defaults to
  ///     `.unbounded`.
  /// - Returns: A stream delivering ``EventSubNotification`` envelopes for `subscription`.
  /// - Throws: ``TwitchAuthenticationError/userAccessTokenRequired`` when the client does
  ///   not hold user OAuth credentials, ``HelixError`` or ``EventSubError`` if WebSocket
  ///   setup or subscription creation fails, or `CancellationError` if setup is cancelled.
  /// - SeeAlso: <doc:EventSub>, ``eventListener(for:callback:)``, ``eventPublisher(for:)``
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

  /// Registers a callback observer for an EventSub subscription.
  ///
  /// Matching subscription descriptions share one upstream Twitch subscription. Call
  /// ``TwitchCancellable/cancel()`` on the returned handle to remove this observer and
  /// schedule upstream unsubscription once no observers remain; releasing the handle alone
  /// does not cancel the subscription.
  ///
  /// - Parameters:
  ///   - subscription: A typed ``EventSubSubscription`` describing the topic and condition.
  ///   - callback: A closure invoked with ``EventSubListenerEvent`` notifications and
  ///     terminal outcomes. Delivery has no main-actor guarantee.
  /// - Returns: A ``TwitchCancellable`` handle that removes this observer when cancelled.
  /// - Throws: ``TwitchAuthenticationError/userAccessTokenRequired`` when the client does
  ///   not hold user OAuth credentials, ``HelixError`` or ``EventSubError`` if WebSocket
  ///   setup or subscription creation fails, or `CancellationError` if setup is cancelled.
  /// - SeeAlso: <doc:EventSub>, ``eventStream(for:bufferingPolicy:)``, ``eventPublisher(for:)``
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
    /// Creates a lazy Combine publisher of EventSub notifications.
    ///
    /// Calling this method opens no WebSocket and creates no remote subscription. Each
    /// downstream subscriber registers independently on its first positive demand, and
    /// cancelling a subscriber removes only its local registration. Matching descriptions
    /// share one upstream Twitch subscription, which is deleted after the last observer
    /// leaves.
    ///
    /// - Important: Notifications arriving while downstream demand is `.none` are dropped
    ///   rather than buffered.
    /// - Parameter subscription: A typed ``EventSubSubscription`` describing the topic and
    ///   condition.
    /// - Returns: A type-erased publisher emitting ``EventSubNotification`` values. Setup
    ///   failures preserve ``TwitchAuthenticationError``, ``HelixError``,
    ///   ``EventSubError``, or `CancellationError`; runtime connection failures and
    ///   revocations arrive as ``EventSubError``.
    /// - SeeAlso: <doc:EventSub>, ``eventStream(for:bufferingPolicy:)``,
    ///   ``eventListener(for:callback:)``
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
