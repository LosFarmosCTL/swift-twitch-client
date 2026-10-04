import Foundation
import Testing

@testable import Twitch

@Suite(.timeLimit(.minutes(1)))
struct IRCRateLimitTests {
  private let session = MockNetworkSession()
  private let credentials = TwitchCredentials(
    oAuth: "token", clientID: "id", userID: "123", userLogin: "tester")

  private func handshake(_ socket: MockWebSocketTask) async {
    await socket.simulateIncoming(
      .string(
        ":tmi.twitch.tv CAP * ACK :twitch.tv/commands twitch.tv/tags\r\n"
          + ":tmi.twitch.tv 001 tester :Welcome, GLHF!\r\n"
          + "@badge-info=;badges=;color=;display-name=tester;emote-sets=0;"
          + "user-id=123;user-type= :tmi.twitch.tv GLOBALUSERSTATE"))
  }

  @Test(arguments: [IRCAccountRateLimiter.Operation.join, .authenticate])
  func rollingWindowBoundsConcurrentAttempts(operation: IRCAccountRateLimiter.Operation)
    async throws
  {
    let window = Duration.milliseconds(40)
    let limiter = IRCAccountRateLimiter(window: window)
    let start = ContinuousClock.now

    try await limiter.acquire(account: "123", operation: operation)

    try await withThrowingTaskGroup(of: Void.self) { group in
      for _ in 0..<20 {
        group.addTask {
          try await limiter.acquire(account: "123", operation: operation)
        }
      }

      try await group.waitForAll()
    }

    #expect(start.duration(to: .now) >= window)
  }

  @Test
  func budgetsAreSeparateByOperationAndAccount() async throws {
    let limiter = IRCAccountRateLimiter(limit: 1, window: .seconds(60)) { _ in
      Issue.record("Independent budgets should not wait for each other")
      throw CancellationError()
    }

    try await limiter.acquire(account: "123", operation: .join)
    try await limiter.acquire(account: "123", operation: .authenticate)
    try await limiter.acquire(account: "456", operation: .join)
    try await limiter.acquire(account: "456", operation: .authenticate)
  }

  @Test
  func queuedJoinDoesNotBlockAcknowledgementsAndPartCancelsIt() async throws {
    let waiting = AsyncStream<Void>.makeStream()
    let limiter = IRCAccountRateLimiter(limit: 1, window: .seconds(60)) { duration in
      waiting.continuation.finish()
      try await Task.sleep(for: duration)
    }

    let pool = IRCConnectionPool(
      with: credentials, network: session, rateLimiter: limiter)
    let pending = Task { try await pool.connect() }

    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    _ = try await pending.value

    try await pool.join(to: "swift")
    await socket.waitForSent("JOIN #swift")

    let queued = Task { try await pool.join(to: "other") }
    for await _ in waiting.stream {}

    var statuses = await pool.channelStatusSnapshots().makeAsyncIterator()
    #expect(await statuses.next() == ["swift": .joining, "other": .joining])

    await socket.simulateIncoming(.string("@room-id=123 :tmi.twitch.tv ROOMSTATE #swift"))
    #expect(await statuses.next() == ["swift": .joined, "other": .joining])

    try await pool.part(from: "other")
    try await queued.value

    #expect(await socket.sentCount(prefix: "JOIN #other") == 0)
    #expect(await socket.didCancel == false)

    await pool.disconnect()
  }

  @Test
  func pooledSocketsShareJoinBudgetIncludingRejoins() async throws {
    let waiting = AsyncStream<Void>.makeStream()
    let limiter = IRCAccountRateLimiter(limit: 2, window: .seconds(60)) { duration in
      waiting.continuation.finish()
      try await Task.sleep(for: duration)
    }

    let first = IRCConnectionPool(
      with: credentials, network: session, rateLimiter: limiter)
    let second = IRCConnectionPool(
      with: credentials, network: session, rateLimiter: limiter)
    let firstConnect = Task { try await first.connect() }

    let firstSocket = await session.waitForTask(at: 0)
    await handshake(firstSocket)
    _ = try await firstConnect.value

    let secondConnect = Task { try await second.connect() }
    let secondSocket = await session.waitForTask(at: 1)
    await handshake(secondSocket)
    _ = try await secondConnect.value

    try await first.join(to: "swift")
    try await second.join(to: "other")
    await firstSocket.waitForSent("JOIN #swift")
    await secondSocket.waitForSent("JOIN #other")

    // A self PART needs to rejoin, using the same already-exhausted account budget.
    await firstSocket.simulateIncoming(
      .string(
        ":tester!tester@tester.tmi.twitch.tv PART #swift"))
    for await _ in waiting.stream {}

    #expect(await firstSocket.sentCount(prefix: "JOIN") == 1)
    #expect(await secondSocket.sentCount(prefix: "JOIN") == 1)

    await first.disconnect()
    await second.disconnect()
  }

  @Test
  func authenticationBudgetIsSharedAndCancellationClosesWaitingSocket() async throws {
    let waiting = AsyncStream<Void>.makeStream()
    let limiter = IRCAccountRateLimiter(limit: 1, window: .seconds(60)) { duration in
      waiting.continuation.finish()
      try await Task.sleep(for: duration)
    }

    let first = IRCConnection(
      credentials: credentials, network: session, rateLimiter: limiter)
    let second = IRCConnection(
      credentials: credentials, network: session, handshakeTimeout: .milliseconds(20),
      rateLimiter: limiter)

    let firstConnect = Task { try await first.connect() }
    let firstSocket = await session.waitForTask(at: 0)
    await handshake(firstSocket)
    _ = try await firstConnect.value

    let secondConnect = Task { try await second.connect() }
    let secondSocket = await session.waitForTask(at: 1)
    for await _ in waiting.stream {}

    #expect(await secondSocket.didResume == false)
    #expect(await secondSocket.sentCount(prefix: "PASS") == 0)

    secondConnect.cancel()
    await #expect(throws: CancellationError.self) { try await secondConnect.value }

    #expect(await secondSocket.didCancel)
    #expect(await firstSocket.didCancel == false)

    await first.disconnect()
  }

  @Test
  func reconnectRejoinsWaitWithoutStartingAcknowledgementTimeout() async throws {
    let waiting = AsyncStream<Void>.makeStream()
    let limiter = IRCAccountRateLimiter(limit: 2, window: .seconds(60)) { duration in
      waiting.continuation.finish()
      try await Task.sleep(for: duration)
    }

    let pool = IRCConnectionPool(
      with: credentials, network: session, joinTimeout: .milliseconds(20),
      rateLimiter: limiter)
    let pending = Task { try await pool.connect() }
    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    _ = try await pending.value

    try await pool.join(to: "swift")
    try await pool.join(to: "other")
    await socket.waitForSent("JOIN", count: 2)

    await socket.simulateIncoming(.string(":tmi.twitch.tv RECONNECT"))
    let replacement = await session.waitForTask(at: 1)
    await handshake(replacement)
    for await _ in waiting.stream {}

    // Let the acknowledgement deadline elapse while both JOINs are still queued.
    try await Task.sleep(for: .milliseconds(40))

    var statuses = await pool.channelStatusSnapshots().makeAsyncIterator()
    #expect(await statuses.next() == ["swift": .joining, "other": .joining])
    #expect(await replacement.sentCount(prefix: "JOIN") == 0)

    await pool.disconnect()

    #expect(await replacement.didCancel)
  }

  @Test
  func anonymousConnectionsBypassBothBudgets() async throws {
    let limiter = IRCAccountRateLimiter(limit: 1, window: .seconds(60)) { _ in
      Issue.record("Anonymous IRC must not use account pacing")
      throw CancellationError()
    }

    for index in 0..<2 {
      let pool = IRCConnectionPool(network: session, rateLimiter: limiter)
      let pending = Task { try await pool.connect() }
      let socket = await session.waitForTask(at: index)
      await handshake(socket)
      _ = try await pending.value

      try await pool.join(to: "swift")
      try await pool.join(to: "other")
      await socket.waitForSent("JOIN #swift")
      await socket.waitForSent("JOIN #other")

      await pool.disconnect()
    }
  }
}
