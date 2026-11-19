import Foundation
import Testing
import TwitchIRC

@testable import Twitch

@Suite(.timeLimit(.minutes(1)))
struct IRCUserStateTests {
  private let session = MockNetworkSession()

  private func setup(_ emotes: String) -> String {
    "@badge-info=;badges=;color=;display-name=tester;emote-sets=\(emotes);"
      + "user-id=user-state-source;user-type= :tmi.twitch.tv GLOBALUSERSTATE"
  }

  private func handshake(_ socket: MockWebSocketTask, emotes: String) async {
    await socket.simulateIncoming(
      .string(
        ":tmi.twitch.tv CAP * ACK :twitch.tv/commands twitch.tv/tags\r\n"
          + ":tmi.twitch.tv 001 tester :Welcome, GLHF!\r\n" + setup(emotes)))
  }

  private var credentials: TwitchCredentials {
    .init(
      accessToken: "token", clientID: "id", userID: UUID().uuidString,
      userLogin: "tester")
  }

  private func joinedChannels(on socket: MockWebSocketTask) async -> [String] {
    await socket.sentMessages.compactMap { message in
      guard case .string(let text) = message else { return nil }
      guard text.hasPrefix("JOIN #") else { return nil }

      return String(text.dropFirst("JOIN #".count))
    }
  }

  @Test
  func chatReportsReaderAndWriterUserStateIndependently() async throws {
    let client = TwitchClient(
      credentials: credentials, chat: .init(reader: .irc(.authenticated), writer: .irc),
      network: session)
    let join = Task { try await client.join(to: ChatChannel(id: "123", login: "swift")) }
    let reader = await session.waitForTask(at: 0)
    await handshake(reader, emotes: "reader")
    await reader.waitForSent("JOIN #swift")
    await reader.simulateIncoming(.string("@room-id=123 :tmi.twitch.tv ROOMSTATE #swift"))
    try await join.value

    let send = Task { try await client.sendIRC(.privateMessage(to: "swift", message: "hi")) }
    let writer = await session.waitForTask(at: 1)
    await handshake(writer, emotes: "writer")
    try await send.value
    _ = try #require(
      await client.chatStateUpdates().first {
        $0.ircReader?.globalUserState?.emoteSets == ["reader"]
          && $0.ircWriter?.globalUserState?.emoteSets == ["writer"]
      })

    let updates = await client.chatStateUpdates()
    await reader.simulateIncoming(.string(":tmi.twitch.tv RECONNECT"))
    let recovering = try #require(await updates.first { $0.reader == .reconnecting })
    #expect(recovering.ircReader?.globalUserState?.emoteSets == ["reader"])
    #expect(recovering.writer == .ready)

    let replacement = await session.waitForTask(at: 2)
    await handshake(replacement, emotes: "replacement")
    let ready = try #require(
      await updates.first { $0.ircReader?.globalUserState?.emoteSets == ["replacement"] })
    #expect(ready.ircWriter?.globalUserState?.emoteSets == ["writer"])
    await client.shutdownChat()
  }

  @Test
  func retiringDesignatedReaderTransfersItsRoleToAnotherReader() async throws {
    let pool = IRCConnectionPool(
      with: credentials, network: session, rateLimiter: IRCAccountRateLimiter(limit: 200))
    let updates = try await pool.start()
    try await pool.join(to: "channel0")
    let primary = await session.waitForTask(at: 0)
    await handshake(primary, emotes: "primary")
    _ = try #require(
      try await updates.nextState {
        $0.globalUserState?.emoteSets == ["primary"]
      })

    try await pool.setChannels((0..<91).map { "channel\($0)" })

    let secondary = await session.waitForTask(at: 1)
    await handshake(secondary, emotes: "secondary")
    _ = try #require(
      try await updates.nextState {
        $0.status == .connected && $0.channels.count == 91
      })
    #expect(await pool.snapshot.globalUserState?.emoteSets == ["primary"])

    await secondary.waitForSent("JOIN")
    let secondaryChannels = await joinedChannels(on: secondary)

    // Keep the secondary's channels and retire the primary through membership requests.
    try await pool.setChannels(secondaryChannels)

    await primary.waitForCancellation()
    _ = try #require(
      try await updates.nextState {
        $0.globalUserState?.emoteSets == ["secondary"]
      })

    await secondary.simulateIncoming(.string(setup("secondary-updated")))
    _ = try #require(
      try await updates.nextState {
        $0.globalUserState?.emoteSets == ["secondary-updated"]
      })

    try await pool.setChannels([])
    await secondary.waitForCancellation()
    let empty = try #require(try await updates.nextState { $0.channels.isEmpty })
    #expect(empty.globalUserState?.emoteSets == ["secondary-updated"])

    try await pool.join(to: "new")
    let fresh = await session.waitForTask(at: 2)
    await handshake(fresh, emotes: "fresh")
    _ = try #require(
      try await updates.nextState {
        $0.globalUserState?.emoteSets == ["fresh"]
      })

    await pool.disconnect()
  }
}
