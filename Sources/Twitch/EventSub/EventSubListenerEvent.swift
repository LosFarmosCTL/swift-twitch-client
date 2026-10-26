/// An EventSub callback delivery containing a notification or a terminal outcome.
public enum EventSubListenerEvent<Event: Sendable>: Sendable {
  /// A decoded EventSub notification.
  case event(Event)
  /// A terminal error that ends delivery.
  case failure(EventSubError)
  /// Normal termination of the observer.
  case finished
}
