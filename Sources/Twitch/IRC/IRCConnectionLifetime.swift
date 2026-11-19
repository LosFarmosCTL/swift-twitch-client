import Foundation

/// Adapter retirement and socket dispatch both invalidate through this lock before
/// asynchronous teardown. The lock is never held across an I/O operation.
internal final class IRCConnectionLifetime: @unchecked Sendable {
  private let lock = NSLock()
  private var isActive = true

  func invalidate() {
    lock.withLock { isActive = false }
  }

  func check() throws { try commit {} }

  func commit<T>(_ action: () -> T) throws -> T {
    try lock.withLock {
      try Task.checkCancellation()
      guard isActive else { throw IRCError.disconnected }
      return action()
    }
  }
}

/// Admission errors occur before writing and must not trigger connection recovery.
internal struct IRCDispatchRefused: Error {
  let underlying: any Error
}
