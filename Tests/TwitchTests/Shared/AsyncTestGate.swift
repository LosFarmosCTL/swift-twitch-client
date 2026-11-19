/// Pauses mocked work until the test explicitly releases it. Release is remembered,
/// including when it races entry; multiple paused operations can share the same gate.
actor AsyncTestGate {
  private var entered = false
  private var released = false
  private var entryWaiters: [CheckedContinuation<Void, Never>] = []
  private var releaseWaiters: [CheckedContinuation<Void, Never>] = []

  func pause() async {
    entered = true
    let waiters = entryWaiters
    entryWaiters.removeAll()
    for waiter in waiters { waiter.resume() }
    if released { return }
    await withCheckedContinuation { releaseWaiters.append($0) }
  }

  func waitUntilEntered() async {
    if entered { return }
    await withCheckedContinuation { entryWaiters.append($0) }
  }

  func release() {
    released = true
    let waiters = releaseWaiters
    releaseWaiters.removeAll()
    for waiter in waiters { waiter.resume() }
  }
}
