import Foundation

/// Serializes the process-local send ledger across clients. IRC dispatch validates its
/// transport and the owning client's credentials before entering the same ledger as Helix.
internal final class ChatSendLimiter: @unchecked Sendable {
  static let shared = ChatSendLimiter()

  struct ChannelRecord: Sendable {
    let sentAt: ContinuousClock.Instant
    let retainUntil: ContinuousClock.Instant
  }

  struct Snapshot: Sendable {
    fileprivate var attempts: [ContinuousClock.Instant] = []
    fileprivate var channels: [String: ChannelRecord] = [:]

    internal var trackedChannelCount: Int { channels.count }
  }

  enum Limit: Sendable {
    case channel(until: ContinuousClock.Instant)
    case account(until: ContinuousClock.Instant)

    var deadline: ContinuousClock.Instant {
      switch self {
      case .channel(let until), .account(let until): until
      }
    }

    func eligibility(now: ContinuousClock.Instant, wallTime: Date) -> ChatSendEligibility {
      let until = wallTime.addingTimeInterval(now.duration(to: deadline).chatTimeInterval)
      switch self {
      case .channel: return .channelCooldown(until: until)
      case .account: return .accountWindow(until: until)
      }
    }
  }

  private let lock = NSLock()
  private let minimumChannelRetention: Duration
  private var accounts: [String: Snapshot] = [:]
  private var observers: [String: [UUID: AsyncStream<Void>.Continuation]] = [:]

  init(minimumChannelRetention: Duration = .seconds(120)) {
    self.minimumChannelRetention = minimumChannelRetention
  }

  func snapshot(for account: String) -> Snapshot {
    lock.withLock { accounts[account] ?? Snapshot() }
  }

  func updates(for account: String) -> AsyncStream<Void> {
    let id = UUID()
    let (stream, continuation) = AsyncStream<Void>.makeStream(
      bufferingPolicy: .bufferingNewest(1))
    continuation.onTermination = { [weak self] _ in
      self?.removeObserver(id, account: account)
    }
    lock.withLock {
      observers[account, default: [:]][id] = continuation
    }
    return stream
  }

  func commit(
    account: String, channel: String, privileged: Bool, interval: Duration,
    enforcesLimits: Bool
  ) -> Limit? {
    let (limit, observers): (Limit?, [AsyncStream<Void>.Continuation]) = lock.withLock {
      let now = ContinuousClock.now
      var snapshot = accounts[account] ?? Snapshot()
      if enforcesLimits,
        let limit = Self.limit(
          snapshot, channel: channel, privileged: privileged, interval: interval, now: now)
      {
        return (limit, [])
      }
      snapshot.attempts.removeAll { $0.duration(to: now) >= .seconds(30) }
      snapshot.channels = snapshot.channels.filter { $0.value.retainUntil > now }
      snapshot.attempts.append(now)
      // Only the latest 100 attempts are needed for either account window.
      if snapshot.attempts.count > 100 {
        snapshot.attempts.removeFirst(snapshot.attempts.count - 100)
      }
      snapshot.channels[channel] = ChannelRecord(
        sentAt: now, retainUntil: now.advanced(by: max(interval, minimumChannelRetention)))
      accounts[account] = snapshot
      pruneExpiredAccounts(except: account, now: now)
      return (nil, Array(observers[account]?.values ?? [:].values))
    }
    // Observers read the latest ledger after a signal, regardless of delivery order.
    for observer in observers { observer.yield(()) }
    return limit
  }

  static func limit(
    _ snapshot: Snapshot, channel: String, privileged: Bool, interval: Duration,
    now: ContinuousClock.Instant
  ) -> Limit? {
    let count = privileged ? 100 : 20
    if snapshot.attempts.count >= count {
      let attempt = snapshot.attempts[snapshot.attempts.count - count]
      let deadline = attempt.advanced(by: .seconds(30))
      if now < deadline { return .account(until: deadline) }
    }
    if !privileged, let last = snapshot.channels[channel]?.sentAt {
      let deadline = last.advanced(by: interval)
      if now < deadline { return .channel(until: deadline) }
    }
    return nil
  }

  private func pruneExpiredAccounts(except current: String, now: ContinuousClock.Instant) {
    for (account, var snapshot) in accounts where account != current {
      snapshot.attempts.removeAll { $0.duration(to: now) >= .seconds(30) }
      snapshot.channels = snapshot.channels.filter { $0.value.retainUntil > now }
      if snapshot.attempts.isEmpty, snapshot.channels.isEmpty {
        accounts.removeValue(forKey: account)
      } else {
        accounts[account] = snapshot
      }
    }
  }

  private func removeObserver(_ id: UUID, account: String) {
    lock.withLock {
      observers[account]?.removeValue(forKey: id)
      if observers[account]?.isEmpty == true { observers.removeValue(forKey: account) }
    }
  }
}

extension Duration {
  fileprivate var chatTimeInterval: TimeInterval {
    let parts = components
    return Double(parts.seconds) + Double(parts.attoseconds) / 1e18
  }
}
