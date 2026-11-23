import Foundation

/// Adapter retirement and socket dispatch both invalidate through this lock before
/// asynchronous teardown. The lock is never held across an I/O operation.
internal final class IRCConnectionLifetime: @unchecked Sendable {
  private let lock = NSLock()
  private var active = true

  var isActive: Bool {
    lock.withLock { active }
  }

  func invalidate() {
    lock.withLock { active = false }
  }

  func check() throws { try commit {} }

  func commit<T>(_ action: () -> T) throws -> T {
    try lock.withLock {
      try Task.checkCancellation()
      guard active else { throw IRCError.disconnected }
      return action()
    }
  }
}

/// Admission errors occur before writing and must not trigger connection recovery.
internal struct IRCDispatchRefused: Error {
  let underlying: any Error
}
