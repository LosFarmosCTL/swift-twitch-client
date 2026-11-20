import Foundation

/// Independent streams registered and finished by the chat owner.
internal struct ChatStreams<Value: Sendable> {
  private var observers: [UUID: AsyncStream<Value>.Continuation] = [:]
  var hasObservers: Bool { !observers.isEmpty }

  mutating func stream(
    bufferingPolicy: AsyncStream<Value>.Continuation.BufferingPolicy,
    initial: Value? = nil,
    finished: Bool,
    onCancel: @escaping @Sendable (UUID) -> Void
  ) -> AsyncStream<Value> {
    let (stream, continuation) = AsyncStream<Value>.makeStream(bufferingPolicy: bufferingPolicy)
    if let initial { continuation.yield(initial) }
    if finished {
      continuation.finish()
    } else {
      let id = UUID()
      observers[id] = continuation
      continuation.onTermination = { _ in onCancel(id) }
    }

    return stream
  }

  mutating func remove(_ id: UUID) { observers[id] = nil }

  func yield(_ value: Value) {
    for observer in observers.values { observer.yield(value) }
  }

  mutating func finish() {
    for observer in observers.values { observer.finish() }
    observers.removeAll()
  }
}
