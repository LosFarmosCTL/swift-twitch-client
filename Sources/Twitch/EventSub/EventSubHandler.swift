import Foundation

internal protocol EventSubHandler: Sendable {
  func yield(_ notification: EventSubNotification<any Event>)
  func finish()
  func finish(throwing error: EventSubError)
}

internal struct EventSubCallbackHandler<T: Event>: EventSubHandler {
  let callback: @Sendable (EventSubListenerEvent<EventSubNotification<T>>) -> Void

  func yield(_ notification: EventSubNotification<any Event>) {
    if let value = notification.typed(as: T.self) {
      callback(.event(value))
    }
  }

  func finish() { callback(.finished) }

  func finish(throwing error: EventSubError) {
    callback(.failure(error))
  }
}
