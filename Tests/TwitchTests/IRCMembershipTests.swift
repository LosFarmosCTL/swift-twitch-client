import Foundation
import Testing

@testable import Twitch

@Suite(.timeLimit(.minutes(1)))
struct IRCMembershipTests {
  private let session = MockNetworkSession()

  private func connect(joinTimeout: Duration = .seconds(15)) async throws
    -> (IRCConnectionPool, MockWebSocketTask)
  {
    let pool = IRCConnectionPool(network: session, joinTimeout: joinTimeout)
    let pending = Task { try await pool.connect() }

    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    _ = try await pending.value

    return (pool, socket)
  }

  private func handshake(_ socket: MockWebSocketTask) async {
    await socket.simulateIncoming(
      .string(
        ":tmi.twitch.tv CAP * ACK :twitch.tv/commands twitch.tv/tags\r\n"
          + ":tmi.twitch.tv 001 justinfan12345 :Welcome, GLHF!"))
  }

  @Test(arguments: ["msg_channel_suspended", "msg_room_not_found"])
  func rejectedJoinIsObservableAndCanBeRetried(code: String) async throws {
    let (pool, socket) = try await connect()
    try await pool.join(to: "swift")

    var statuses = await pool.channelStatusSnapshots().makeAsyncIterator()
    #expect(await statuses.next() == ["swift": .joining])

    await socket.simulateIncoming(
      .string(
        "@msg-id=\(code) :tmi.twitch.tv NOTICE #swift :Unavailable"))

    #expect(
      await statuses.next() == [
        "swift": .failed(.joinRejected(code: code, message: "Unavailable"))
      ])

    try await pool.retryChannel("swift")
    await socket.waitForSent("JOIN #swift", count: 2)

    #expect(await socket.sentCount(prefix: "JOIN #swift") == 2)
    #expect(await statuses.next() == ["swift": .joining])

    await pool.disconnect()
  }

  @Test
  func timeoutIsObservableAndAcknowledgedRetryStaysJoined() async throws {
    let (pool, socket) = try await connect(joinTimeout: .milliseconds(30))
    try await pool.join(to: "swift")

    var statuses = await pool.channelStatusSnapshots().makeAsyncIterator()
    _ = await statuses.next()
    #expect(await statuses.next() == ["swift": .failed(.joinTimedOut)])

    try await pool.retryChannel("swift")
    _ = await statuses.next()
    await socket.simulateIncoming(
      .string(
        "@room-id=123 :tmi.twitch.tv ROOMSTATE #swift"))

    #expect(await statuses.next() == ["swift": .joined])

    try await pool.join(to: "other")
    var observedTimeout = false

    while let snapshot = await statuses.next() {
      #expect(snapshot["swift"] == .joined)

      if snapshot["other"] == .failed(.joinTimedOut) {
        observedTimeout = true
        break
      }
    }

    #expect(observedTimeout)

    await pool.disconnect()
  }

  @Test
  func emptySocketIsRetiredAndLaterJoinUsesNewSocket() async throws {
    let (pool, socket) = try await connect()
    try await pool.join(to: "swift")
    try await pool.part(from: "swift")
    await socket.waitForCancellation()

    #expect(await socket.didCancel)
    var statuses = await pool.channelStatusSnapshots().makeAsyncIterator()
    #expect(await statuses.next() == [:])

    try await pool.join(to: "other")
    let replacement = await session.waitForTask(at: 1)
    await handshake(replacement)
    await replacement.waitForSent("JOIN #other")

    #expect(await replacement.sentCount(prefix: "JOIN #swift") == 0)
    await pool.disconnect()
  }

  @Test
  func partDuringReplacementHandshakeRetiresSocket() async throws {
    let (pool, socket) = try await connect()
    try await pool.join(to: "swift")

    await socket.simulateIncoming(.string(":tmi.twitch.tv RECONNECT"))
    let replacement = await session.waitForTask(at: 1)
    await replacement.waitForSent("NICK")

    try await pool.part(from: "swift")
    await replacement.waitForCancellation()

    #expect(await replacement.didCancel)
    await handshake(replacement)
    #expect(await replacement.sentCount(prefix: "JOIN") == 0)

    await pool.disconnect()
  }
}
