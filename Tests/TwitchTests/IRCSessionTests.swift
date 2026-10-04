import Foundation
import Testing
import TwitchIRC

@testable import Twitch

@Suite(.timeLimit(.minutes(1)))
struct IRCSessionTests {
  let session = MockNetworkSession()

  func handshake(_ socket: MockWebSocketTask, userID: String? = nil) async {
    var lines = [
      ":tmi.twitch.tv CAP * ACK :twitch.tv/commands twitch.tv/tags",
      ":tmi.twitch.tv 001 justinfan12345 :Welcome, GLHF!",
    ]

    if let userID {
      lines.append(
        "@badge-info=;badges=;color=;display-name=tester;emote-sets=0,123;"
          + "user-id=\(userID);user-type= :tmi.twitch.tv GLOBALUSERSTATE")
    }

    await socket.simulateIncoming(.string(lines.joined(separator: "\r\n")))
  }

  @Test
  func constructionAndMembershipPerformNoNetworking() async throws {
    let client = TwitchIRCClient(.anonymous, mode: .receiveOnly, network: session)
    var states = await client.stateUpdates().makeAsyncIterator()
    #expect(await states.next()?.status == .idle)

    try await client.setDesiredChannels(["#SWIFT", "swift", "other"])
    let desired = await client.stateUpdates().first {
      $0.channels == ["swift": .joining, "other": .joining]
    }
    #expect(desired?.status == .idle)

    try await client.requestPart(from: "#OTHER")
    _ = try #require(
      await client.stateUpdates().first {
        $0.channels == ["swift": .joining]
      })
    #expect(await session.taskCount() == 0)

    await client.shutdown()
    var final: IRCState?

    while let state = await states.next() { final = state }

    #expect(final?.status == .shutdown)
    #expect(final?.channels.isEmpty == true)
    #expect(final?.recoveries.isEmpty == true)

    var messages = await client.messages().makeAsyncIterator()
    #expect(try await messages.next() == nil)
    await #expect(throws: IRCError.self) { try await client.connect() }
  }

  @Test
  func observersRegisteredBeforeConnectReceiveAndRetainSetupState() async throws {
    let credentials = TwitchCredentials(
      oAuth: "token", clientID: "id", userID: "setup-observer", userLogin: "tester")
    let client = TwitchIRCClient(
      .authenticated(credentials), mode: .receiveOnly, network: session)

    var messages = await client.messages().makeAsyncIterator()
    let updates = await client.stateUpdates()
    try await client.setDesiredChannels(["swift"])

    let pending = Task { try await client.connect() }
    let socket = await session.waitForTask(at: 0)
    await handshake(socket, userID: credentials.userID)
    try await pending.value

    let message = try #require(try await messages.next())

    guard case .globalUserState(let userState) = message else {
      Issue.record("Initial setup event was lost")
      await client.shutdown()
      return
    }

    #expect(userState.emoteSets == ["0", "123"])

    let retained = try #require(
      await updates.first { $0.globalUserState?.userId == credentials.userID })

    #expect(retained.globalUserState?.emoteSets == ["0", "123"])

    let refreshed = await client.stateUpdates()
    await socket.simulateIncoming(
      .string(
        "@badge-info=;badges=;color=;display-name=tester;emote-sets=456;"
          + "user-id=\(credentials.userID);user-type= :tmi.twitch.tv GLOBALUSERSTATE"))
    _ = try #require(await refreshed.first { $0.globalUserState?.emoteSets == ["456"] })

    try await client.setDesiredChannels(["swift", "other"])
    let changed = try #require(
      await client.stateUpdates().first {
        $0.channels.keys.contains("other")
      })
    #expect(changed.globalUserState?.emoteSets == ["456"])

    var late = await client.stateUpdates().makeAsyncIterator()
    #expect(await late.next()?.globalUserState?.emoteSets == ["456"])

    await client.shutdown()
  }

  @Test
  func initialTransientFailuresExposeRetryDetailsAndRecover() async throws {
    let client = TwitchIRCClient(.anonymous, mode: .receiveOnly, network: session)
    try await client.setDesiredChannels(["swift"])
    let updates = await client.stateUpdates()

    let pending = Task { try await client.connect() }
    let first = await session.waitForTask(at: 0)
    await first.simulateError(URLError(.networkConnectionLost))

    let recovering = try #require(
      await updates.first { $0.recoveries.first?.retryAt != nil })

    #expect(recovering.status == .reconnecting)
    #expect(recovering.channels == ["swift": .reconnecting])

    let retry = try #require(recovering.recoveries.first)
    #expect(retry.attempt == 1)
    #expect(retry.role == .read)
    #expect(retry.channels == ["swift"])

    guard case .connectionFailed = retry.reason else {
      Issue.record("Missing structured failure reason")
      pending.cancel()
      _ = try? await pending.value
      return
    }

    let second = await session.waitForTask(at: 1)
    await second.simulateError(URLError(.cannotConnectToHost))

    let nextUpdates = await client.stateUpdates()
    let nextRetry = try #require(
      await nextUpdates.first { $0.recoveries.first?.attempt == 2 })

    #expect(nextRetry.recoveries.first?.connectionID == retry.connectionID)

    let third = await session.waitForTask(at: 2)
    await handshake(third)
    try await pending.value
    await third.waitForSent("JOIN #swift")

    let connected = try #require(
      await client.stateUpdates().first { $0.status == .connected })
    #expect(connected.recoveries.isEmpty)
    #expect(await first.didCancel)
    #expect(await second.didCancel)

    await client.shutdown()
  }

  @Test(arguments: [TwitchIRCClient.Mode.receiveOnly, .readWrite])
  func connectCancellationEndsTheSessionAndAllObservers(mode: TwitchIRCClient.Mode)
    async throws
  {
    let client = TwitchIRCClient(.anonymous, mode: mode, network: session)
    try await client.setDesiredChannels(["swift"])

    var messages = await client.messages().makeAsyncIterator()
    var states = await client.stateUpdates().makeAsyncIterator()
    _ = await states.next()

    let pending = Task { try await client.connect() }
    let socket = await session.waitForTask(at: 0)
    await socket.waitForSent("NICK")

    pending.cancel()
    await #expect(throws: CancellationError.self) { try await pending.value }

    #expect(await socket.didCancel)
    var final: IRCState?

    while let state = await states.next() { final = state }

    #expect(final?.status == .shutdown)
    #expect(final?.channels.isEmpty == true)
    #expect(try await messages.next() == nil)

    await #expect(throws: IRCError.self) { try await client.connect() }
  }

  @Test
  func failedJoinsRequireExplicitRetryAndSetChannelsPreservesFailures() async throws {
    let client = TwitchIRCClient(.anonymous, mode: .receiveOnly, network: session)
    try await client.setDesiredChannels(["swift", "other"])

    let pending = Task { try await client.connect() }
    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    try await pending.value
    await socket.waitForSent("JOIN", count: 2)

    let updates = await client.stateUpdates()
    await socket.simulateIncoming(
      .string("@msg-id=msg_room_not_found :tmi.twitch.tv NOTICE #swift :Unavailable"))

    let failed = try #require(
      await updates.first {
        $0.channels["swift"]
          == .failed(
            .joinRejected(code: "msg_room_not_found", message: "Unavailable"))
      })

    try await client.requestJoin(to: "#SWIFT")
    try await client.setDesiredChannels(["swift", "other"])

    #expect(await client.state.channels == failed.channels)
    #expect(await socket.sentCount(prefix: "JOIN #swift") == 1)

    try await client.retryChannel("#SWIFT")
    _ = try #require(
      await client.stateUpdates().first { $0.channels["swift"] == .joining })
    await socket.waitForSent("JOIN #swift", count: 2)

    try await client.retryChannel("absent")
    #expect(await client.state.channels["absent"] == nil)

    await client.shutdown()
  }

  @Test
  func setChannelsDuringRecoveryReconcilesLatestIntent() async throws {
    let client = TwitchIRCClient(.anonymous, mode: .receiveOnly, network: session)
    try await client.setDesiredChannels(["swift", "removed"])

    let pending = Task { try await client.connect() }
    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    try await pending.value
    await socket.waitForSent("JOIN", count: 2)

    let updates = await client.stateUpdates()
    await socket.simulateIncoming(.string(":tmi.twitch.tv RECONNECT"))
    let recovering = try #require(await updates.first { !$0.recoveries.isEmpty })
    #expect(recovering.recoveries.first?.reason == .serverRequestedReconnect)

    try await client.setDesiredChannels(["swift", "#ADDED", "added"])
    _ = try #require(
      await client.stateUpdates().first {
        Set($0.channels.keys) == ["swift", "added"]
      })

    let replacement = await session.waitForTask(at: 1)
    await handshake(replacement)
    await replacement.waitForSent("JOIN", count: 2)

    #expect(await replacement.sentCount(prefix: "JOIN #removed") == 0)
    #expect(await replacement.sentCount(prefix: "JOIN #added") == 1)

    await client.shutdown()
  }

  @Test(arguments: ["Login authentication failed", "Improperly formatted auth"])
  func terminalFailureFinishesCurrentAndLateObserversWithRetainedReason(notice: String)
    async throws
  {
    let client = TwitchIRCClient(.anonymous, mode: .receiveOnly, network: session)
    try await client.setDesiredChannels(["swift"])

    var messages = await client.messages().makeAsyncIterator()
    var states = await client.stateUpdates().makeAsyncIterator()

    let pending = Task { try await client.connect() }
    let socket = await session.waitForTask(at: 0)
    await socket.simulateIncoming(
      .string(":tmi.twitch.tv NOTICE * :\(notice)"))

    await #expect(throws: IRCError.self) { try await pending.value }
    var final: IRCState?

    while let state = await states.next() { final = state }

    #expect(final?.status == .failed(.authenticationFailed))
    #expect(final?.channels == ["swift": .failed(.authenticationFailed)])
    #expect(final?.recoveries.isEmpty == true)
    await #expect(throws: IRCError.self) { try await messages.next() }

    var late = await client.stateUpdates().makeAsyncIterator()
    let retained = try #require(await late.next())

    #expect(retained.status == final?.status)
    #expect(retained.channels == final?.channels)
    #expect(retained.recoveries == final?.recoveries)
    #expect(await late.next() == nil)

    await client.shutdown()
    #expect(await client.state.status == .failed(.authenticationFailed))
  }
}

extension IRCSessionTests {
  @Test
  func concurrentConnectIsRejectedAndObserverCancellationKeepsSessionActive() async throws
  {
    let client = TwitchIRCClient(.anonymous, mode: .receiveOnly, network: session)
    let observed = AsyncStream<Void>.makeStream()
    let states = await client.stateUpdates()
    let observer = Task {
      for await _ in states {
        observed.continuation.finish()
      }
    }

    for await _ in observed.stream {}
    observer.cancel()
    await observer.value

    var first = await client.messages().makeAsyncIterator()
    var second = await client.messages().makeAsyncIterator()

    let pending = Task { try await client.connect() }
    let socket = await session.waitForTask(at: 0)

    let error = await #expect(throws: IRCError.self) { try await client.connect() }

    if case .alreadyConnected = error {
    } else {
      Issue.record("Expected concurrent rejection")
    }

    await handshake(socket)
    try await pending.value

    await socket.simulateIncoming(
      .string(":tester!tester@tester.tmi.twitch.tv JOIN #swift"))

    guard case .join = try await first.next() else {
      Issue.record("First observer must receive the message")
      await client.shutdown()
      return
    }

    guard case .join = try await second.next() else {
      Issue.record("Second observer must receive the message")
      await client.shutdown()
      return
    }

    #expect(await socket.didCancel == false)
    await #expect(throws: IRCError.self) {
      try await client.sendMessage("hello", to: "swift")
    }

    await client.shutdown()
  }

  @Test
  func factoryCapturesCredentialsWithoutStartingNetworking() async throws {
    let original = TwitchCredentials(
      oAuth: "original-token", clientID: "id", userID: "original", userLogin: "tester")
    let twitch = TwitchClient(authentication: original, network: session)
    let client = await twitch.makeIRCClient(mode: .receiveOnly)

    await twitch.switchCredentials(
      to: .init(oAuth: "new-token", clientID: "id", userID: "new", userLogin: "other"))
    #expect(await session.taskCount() == 0)

    let pending = Task { try await client.connect() }
    let socket = await session.waitForTask(at: 0)
    await handshake(socket, userID: original.userID)
    try await pending.value

    #expect(await socket.sentCount(prefix: "PASS oauth:original-token") == 1)
    #expect(await socket.sentCount(prefix: "NICK tester") == 1)

    await client.shutdown()
  }
}
