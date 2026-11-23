import Foundation
import Testing

@testable import Twitch

@Suite(.timeLimit(.minutes(1)))
struct IRCMembershipTests {
  private let session = MockNetworkSession()

  private func connect(joinTimeout: Duration = .seconds(15)) async throws
    -> (IRCConnectionPool, MockWebSocketTask, AsyncThrowingStream<IRCConnectionPool.Update, any Error>)
  {
    let pool = IRCConnectionPool(network: session, joinTimeout: joinTimeout)
    let updates = try await pool.start()
    try await pool.join(to: "swift")

    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    await socket.waitForSent("JOIN #swift")

    return (pool, socket, updates)
  }

  private func handshake(_ socket: MockWebSocketTask) async {
    await socket.simulateIncoming(
      .string(
        ":tmi.twitch.tv CAP * ACK :twitch.tv/commands twitch.tv/tags\r\n"
          + ":tmi.twitch.tv 001 justinfan12345 :Welcome, GLHF!"))
  }

  @Test(arguments: ["msg_channel_suspended", "msg_room_not_found"])
  func rejectedJoinIsObservableAndCanBeRetried(code: String) async throws {
    let (pool, socket, updates) = try await connect()

    await socket.simulateIncoming(
      .string(
        "@msg-id=\(code) :tmi.twitch.tv NOTICE #swift :Unavailable"))

    _ = try #require(
      try await updates.nextState {
        $0.channels["swift"] == .failed(.joinRejected(code: code, message: "Unavailable"))
      })

    try await pool.setChannels(["swift"], retrying: ["swift"])
    await socket.waitForSent("JOIN #swift", count: 2)

    #expect(await socket.sentCount(prefix: "JOIN #swift") == 2)
    #expect(await pool.snapshot.channels == ["swift": .joining])

    await pool.disconnect()
  }

  @Test
  func timeoutIsObservableAndAcknowledgedRetryStaysJoined() async throws {
    let (pool, socket, updates) = try await connect(joinTimeout: .milliseconds(30))
    _ = try #require(
      try await updates.nextState { $0.channels["swift"] == .failed(.joinTimedOut) })

    try await pool.setChannels(["swift"], retrying: ["swift"])
    await socket.waitForSent("JOIN #swift", count: 2)
    await socket.simulateIncoming(
      .string(
        "@room-id=123 :tmi.twitch.tv ROOMSTATE #swift"))

    _ = try #require(try await updates.nextState { $0.channels["swift"] == .joined })

    try await pool.join(to: "other")
    let state = try #require(
      try await updates.nextState { $0.channels["other"] == .failed(.joinTimedOut) })
    #expect(state.channels["swift"] == .joined)

    await pool.disconnect()
  }

  @Test
  func emptySocketIsRetiredAndLaterJoinUsesNewSocket() async throws {
    let (pool, socket, _) = try await connect()
    try await pool.part(from: "swift")
    await socket.waitForCancellation()

    #expect(await socket.didCancel)
    #expect(await pool.snapshot.channels.isEmpty)

    try await pool.join(to: "other")
    let replacement = await session.waitForTask(at: 1)
    await handshake(replacement)
    await replacement.waitForSent("JOIN #other")

    #expect(await replacement.sentCount(prefix: "JOIN #swift") == 0)
    await pool.disconnect()
  }

  @Test
  func partDuringReplacementHandshakeRetiresSocket() async throws {
    let (pool, socket, _) = try await connect()

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
