/// A delivery sent to an EventSub callback registered with ``TwitchClient/eventListener(for:callback:)``.
///
/// - SeeAlso: <doc:EventSub>, ``EventSubNotification``, ``EventSubError``
public enum EventSubListenerEvent<Event: Sendable>: Sendable {
  /// A decoded notification delivered by Twitch.
  case event(Event)
  /// A terminal error that ended the subscription or its underlying WebSocket session.
  case failure(EventSubError)
  /// Normal termination of the observer (for example, after cancellation,
  /// ``TwitchClient/resetEventSub()``, or ``TwitchClient/switchCredentials(to:chatBehavior:)``).
  case finished
}
