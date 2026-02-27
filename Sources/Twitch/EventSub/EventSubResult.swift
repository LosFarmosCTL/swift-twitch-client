public enum EventSubResult<Event: Sendable>: Sendable {
  case event(Event)
  case failure(EventSubError)
  case finished
}
