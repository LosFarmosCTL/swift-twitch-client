import Foundation

internal actor IRCAccountRateLimiter {
  enum Operation: Hashable {
    case join
    case authenticate
  }

  private struct Key: Hashable {
    let account: String
    let operation: Operation
  }

  static let shared = IRCAccountRateLimiter()

  private let limit: Int
  private let window: Duration
  private let sleep: @Sendable (Duration) async throws -> Void

  private var attempts: [Key: [ContinuousClock.Instant]] = [:]

  init(
    limit: Int = 20,
    window: Duration = .seconds(10),
    sleep: @escaping @Sendable (Duration) async throws -> Void = {
      try await Task.sleep(for: $0)
    }
  ) {
    precondition(limit > 0 && window > .zero)

    self.limit = limit
    self.window = window
    self.sleep = sleep
  }

  func acquire(account: String, operation: Operation) async throws {
    let key = Key(account: account, operation: operation)

    while true {
      try Task.checkCancellation()
      let now = ContinuousClock.now

      attempts = attempts.compactMapValues { values in
        let current = values.filter { $0.advanced(by: window) > now }
        return if current.isEmpty { nil } else { current }
      }

      let current = attempts[key, default: []]

      if current.count < limit {
        attempts[key, default: []].append(now)
        return
      }

      if let first = current.first {
        try await sleep(now.duration(to: first.advanced(by: window)))
      }
    }
  }
}
