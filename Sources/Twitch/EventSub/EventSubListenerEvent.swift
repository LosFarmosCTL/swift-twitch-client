public enum EventSubListenerEvent<Event: Sendable>: Sendable {
  case event(Event)
  case failure(EventSubError)
  case finished
}
