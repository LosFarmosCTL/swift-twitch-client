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
    .init(oAuth: "token", clientID: "id", userID: UUID().uuidString, userLogin: "tester")
  }

  private func joinedChannels(on socket: MockWebSocketTask) async -> [String] {
    await socket.sentMessages.compactMap { message in
      guard case .string(let text) = message else { return nil }
      guard text.hasPrefix("JOIN #") else { return nil }

      return String(text.dropFirst("JOIN #".count))
    }
  }

  @Test(arguments: [TwitchIRCClient.Mode.receiveOnly, .readWrite])
  func readerSuppliesStateAcrossReconnectsInEitherMode(mode: TwitchIRCClient.Mode)
    async throws
  {
    let client = TwitchIRCClient(
      .authenticated(credentials), mode: mode, network: session)
    try await client.setDesiredChannels(["swift"])
    let pending = Task { try await client.connect() }
    var writer: MockWebSocketTask?

    if mode == .readWrite {
      writer = await session.waitForTask(at: 0)
      await handshake(try #require(writer), emotes: "writer")
    }

    let readIndex = if mode == .readWrite { 1 } else { 0 }
    let reader = await session.waitForTask(at: readIndex)
    await handshake(reader, emotes: "reader")
    try await pending.value
    _ = try #require(
      await client.stateUpdates().first {
        $0.globalUserState?.emoteSets == ["reader"]
      })

    let updates = await client.stateUpdates()
    await reader.simulateIncoming(.string(":tmi.twitch.tv RECONNECT"))
    let recovering = try #require(await updates.first { $0.status == .reconnecting })
    #expect(recovering.globalUserState?.emoteSets == ["reader"])

    let replacement = await session.waitForTask(at: readIndex + 1)
    await handshake(replacement, emotes: "replacement")
    _ = try #require(
      await client.stateUpdates().first {
        $0.status == .connected && $0.globalUserState?.emoteSets == ["replacement"]
      })

    if let writer {
      let writeUpdates = await client.stateUpdates()
      await writer.simulateIncoming(
        .string(setup("ignored") + "\r\n:tmi.twitch.tv RECONNECT"))
      let writeRecovery = try #require(
        await writeUpdates.first { $0.status == .reconnecting })
      #expect(writeRecovery.globalUserState?.emoteSets == ["replacement"])
    }

    await client.shutdown()
  }

  @Test
  func retiringDesignatedReaderTransfersItsRoleToAnotherReader() async throws {
    let pool = IRCConnectionPool(
      with: credentials, network: session, rateLimiter: IRCAccountRateLimiter(limit: 200))
    let pending = Task { try await pool.connect() }
    let primary = await session.waitForTask(at: 0)
    await handshake(primary, emotes: "primary")
    var messages = try await pending.value.makeAsyncIterator()
    _ = try await messages.next()
    _ = try #require(
      await pool.stateUpdates().first {
        $0.globalUserState?.emoteSets == ["primary"]
      })

    try await pool.setChannels((0..<91).map { "channel\($0)" })

    let secondary = await session.waitForTask(at: 1)
    await handshake(secondary, emotes: "secondary")
    _ = try await messages.next()
    _ = try #require(
      await pool.stateUpdates().first {
        $0.status == .connected && $0.channels.count == 91
      })
    #expect(await pool.snapshot.globalUserState?.emoteSets == ["primary"])

    await secondary.waitForSent("JOIN")
    let secondaryChannels = await joinedChannels(on: secondary)

    // Keep the secondary's channels and retire the primary through membership requests.
    try await pool.setChannels(secondaryChannels)

    await primary.waitForCancellation()
    _ = try #require(
      await pool.stateUpdates().first {
        $0.globalUserState?.emoteSets == ["secondary"]
      })

    let updates = await pool.stateUpdates()
    await secondary.simulateIncoming(.string(setup("secondary-updated")))
    _ = try #require(
      await updates.first {
        $0.globalUserState?.emoteSets == ["secondary-updated"]
      })

    try await pool.setChannels([])
    await secondary.waitForCancellation()
    let empty = try #require(await pool.stateUpdates().first { $0.channels.isEmpty })
    #expect(empty.globalUserState?.emoteSets == ["secondary-updated"])

    try await pool.join(to: "new")
    let fresh = await session.waitForTask(at: 2)
    await handshake(fresh, emotes: "fresh")
    _ = try #require(
      await pool.stateUpdates().first {
        $0.globalUserState?.emoteSets == ["fresh"]
      })

    await pool.disconnect()
  }
}
