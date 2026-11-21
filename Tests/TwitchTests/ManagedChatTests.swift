import Foundation
import Testing

@testable import Twitch

@Suite(.timeLimit(.minutes(1)))
struct ManagedChatTests {
  let session = MockNetworkSession()
  let channel = ChatChannel(id: "123", login: "swift")
  let first = TwitchCredentials(
    accessToken: "first-token", clientID: "app", userID: UUID().uuidString,
    userLogin: "first")
  let second = TwitchCredentials(
    accessToken: "second-token", clientID: "app", userID: UUID().uuidString,
    userLogin: "second")

  func client(
    reader: ChatConfiguration.Reader = .irc(.anonymous),
    writer: ChatConfiguration.Writer = .helix
  ) -> TwitchClient {
    TwitchClient(
      credentials: first, chat: .init(reader: reader, writer: writer), network: session)
  }

  func handshake(
    _ socket: MockWebSocketTask, authenticated user: TwitchCredentials? = nil
  ) async {
    let nick = user?.userLogin ?? "justinfan12345"
    var frame =
      ":tmi.twitch.tv CAP * ACK :twitch.tv/commands twitch.tv/tags\r\n"
      + ":tmi.twitch.tv 001 \(nick) :Welcome, GLHF!"
    if let user {
      frame +=
        "\r\n@badge-info=;badges=;color=;display-name=\(nick);emote-sets=;"
        + "user-id=\(user.userID!);user-type= :tmi.twitch.tv GLOBALUSERSTATE"
    }
    await socket.simulateIncoming(.string(frame))
  }

  func acknowledge(_ socket: MockWebSocketTask) async {
    await socket.waitForSent("JOIN #swift")
    await socket.simulateIncoming(
      .string(
        "@room-id=123;emote-only=0;subs-only=0;r9k=0;slow=0;followers-only=-1 :tmi.twitch.tv ROOMSTATE #swift"
      ))
  }

  func stubSending() async {
    await session.stub(
      url: URL(string: "https://api.twitch.tv/helix/chat/messages")!, method: "POST",
      body: Data(
        #"{"data":[{"message_id":"message","is_sent":true,"drop_reason":null}]}"#.utf8))
  }

  func stubChannelLookup(parameter: String, value: String) async {
    let url = URL(string: "https://api.twitch.tv/helix/users")!.appending(
      queryItems: [.init(name: parameter, value: value)])
    let body = """
      {"data":[{
        "id":"123", "login":"swift", "display_name":"Swift", "type":"",
        "broadcaster_type":"", "description":"", "offline_image_url":"", "view_count":0,
        "profile_image_url":"https://example.com/image.png", "created_at":"2020-01-01T00:00:00Z"
      }]}
      """
    await session.stub(url: url, body: Data(body.utf8))
  }

  @Test
  func credentialChangesBeforeObservingChatReportLatestTransition() async {
    let client = client()
    await client.switchCredentials(to: second)
    await client.resetEventSub()
    await client.switchCredentials(to: first, chatBehavior: .partChannels)

    let state = await client.chatState
    #expect(state.credentialRevision == 2)
    #expect(
      state.credentialChange
        == ChatCredentialChange(
          revision: 2, previousUserID: second.userID, userID: first.userID,
          behavior: .partChannels, anonymousReaderPreserved: false))
  }

  @Test
  func anonymousReaderSurvivesSwitchAndStateReportsPolicyAndIdentity() async throws {
    let client = client()
    let updates = await client.chatStateUpdates()
    let pending = Task { try await client.join(to: channel) }
    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    await acknowledge(socket)
    try await pending.value
    await client.setChatPrivilege(ChatPrivilege(isVIP: true), in: channel.id)
    await client.switchCredentials(to: second)
    let changed = try #require(await updates.first { $0.credentialChange?.revision == 1 })
    #expect(changed.userID == second.userID)
    #expect(changed.credentialChange?.anonymousReaderPreserved == true)
    #expect(changed.credentialChange?.previousUserID == first.userID)
    #expect(changed.channels[channel.id]?.status == .ready)
    #expect(changed.channels[channel.id]?.privilege == .unknown)
    #expect(await socket.didCancel == false)
    #expect(await session.taskCount() == 1)

    await client.switchCredentials(to: first, chatBehavior: .partChannels)
    await socket.waitForCancellation()
    let parted = await client.chatState
    #expect(parted.channels.isEmpty)
    #expect(parted.lastDeparture?.reason == .credentialsChanged)
    #expect(parted.credentialChange?.behavior == .partChannels)
    #expect(parted.credentialChange?.anonymousReaderPreserved == false)
    await client.shutdownChat()
  }

  @Test
  func authenticatedReaderRestartsAndOldJoinWaiterDoesNotFollowNewIdentity() async throws {
    let client = client(reader: .irc(.authenticated))
    let pending = Task { try await client.join(to: channel) }
    let old = await session.waitForTask(at: 0)
    await client.switchCredentials(to: second)
    await #expect(throws: ChatError.credentialsChanged) { try await pending.value }
    await old.waitForCancellation()
    let replacement = await session.waitForTask(at: 1)
    await handshake(replacement, authenticated: second)
    await acknowledge(replacement)
    _ = try #require(
      await client.chatStateUpdates().first { $0.channels[channel.id]?.status == .ready })
    #expect(await session.taskCount() == 2)
    #expect(await replacement.sentCount(prefix: "PASS oauth:second-token") == 1)
    #expect(await client.chatState.credentialChange?.anonymousReaderPreserved == false)
    await client.shutdownChat()
  }

  @Test
  func aliasesShareSetupAndCancellingOneJoinWaiterDoesNotPartMembership() async throws {
    let client = client()
    let cancelled = Task { try await client.join(to: channel) }
    let socket = await session.waitForTask(at: 0)
    let remaining = Task { try await client.join(to: .login("#SWIFT")) }
    while await client.chatReadinessWaiterCount < 2 { await Task.yield() }
    cancelled.cancel()
    await #expect(throws: CancellationError.self) { try await cancelled.value }
    #expect(await socket.didCancel == false)
    await handshake(socket)
    await acknowledge(socket)
    try await remaining.value
    #expect(await socket.sentCount(prefix: "JOIN #swift") == 1)
    #expect(await session.requestCount() == 0)
    #expect(await client.chatState.channels.count == 1)
    try await client.part(from: .id(channel.id))
    await socket.waitForCancellation()
    #expect(await client.chatState.channels.isEmpty)
    await client.shutdownChat()
  }

  @Test
  func pendingJoinsReceiveTheirOwnDepartureReason() async throws {
    let client = client()
    let first = Task { try await client.join(to: channel) }
    let other = ChatChannel(id: "456", login: "other")
    let second = Task { try await client.join(to: other) }
    while await client.chatReadinessWaiterCount < 2 { await Task.yield() }

    // Run both departures in a single actor turn, before either waiter resumes.
    await client.partAndShutdownForTesting(channel)

    await #expect(throws: ChatError.parted) { try await first.value }
    await #expect(throws: ChatError.shutdown) { try await second.value }
  }

  @Test
  func cancelledIdentityLookupWaiterDoesNotCancelSharedLookupOrStartAnotherRequest()
    async throws
  {
    let client = client()
    let entered = AsyncStream<Void>.makeStream()
    let release = AsyncStream<Void>.makeStream()
    await stubChannelLookup(parameter: "login", value: "swift")
    await session.onRequest { _ in
      entered.continuation.yield(())
      _ = await release.stream.first { _ in true }
    }
    let cancelled = Task { try await client.join(to: .login("swift")) }
    _ = await entered.stream.first { _ in true }
    let remaining = Task { try await client.join(to: .login("#SWIFT")) }
    cancelled.cancel()
    await #expect(throws: CancellationError.self) { try await cancelled.value }
    #expect(await session.taskCount() == 0)
    release.continuation.yield(())
    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    await acknowledge(socket)
    try await remaining.value
    #expect(await session.requestCount() == 1)
    #expect(await client.chatState.channels.count == 1)
    await client.shutdownChat()
  }

  @Test
  func partDuringIdentityLookupPreventsLateJoinButAllowsExplicitRejoin() async throws {
    let client = client()
    let entered = AsyncStream<Void>.makeStream()
    let release = AsyncStream<Void>.makeStream()
    await stubChannelLookup(parameter: "id", value: "123")
    await session.onRequest { _ in
      entered.continuation.yield(())
      _ = await release.stream.first { _ in true }
    }
    let pending = Task { try await client.requestJoin(to: .id(channel.id)) }
    _ = await entered.stream.first { _ in true }
    await client.part(from: channel)
    await #expect(throws: ChatError.parted) { try await pending.value }
    release.continuation.yield(())
    #expect(await client.chatState.channels.isEmpty)
    #expect(await session.taskCount() == 0)

    let rejoin = Task { try await client.join(to: channel) }
    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    await acknowledge(socket)
    try await rejoin.value
    #expect(await client.chatState.channels[channel.id]?.status == .ready)
    await client.shutdownChat()
  }

  @Test
  func partByIDWithdrawsAnOlderJoinByAnUncachedLogin() async throws {
    let client = client()
    let lookup = AsyncTestGate()
    await stubChannelLookup(parameter: "login", value: channel.login)
    await session.onRequest { _ in await lookup.pause() }

    let oldJoin = Task { try await client.requestJoin(to: .login("SWIFT")) }
    await lookup.waitUntilEntered()
    try await client.part(from: .id(channel.id))
    await lookup.release()
    await #expect(throws: ChatError.parted) { try await oldJoin.value }
    #expect(await client.chatState.channels.isEmpty)
    #expect(await session.taskCount() == 0)

    let latestJoin = Task { try await client.join(to: .login(channel.login)) }
    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    await acknowledge(socket)
    try await latestJoin.value
    #expect(await session.requestCount() == 1)
    #expect(await client.chatState.channels[channel.id]?.status == .ready)
    await client.shutdownChat()
  }

  @Test
  func coalescedRejoinReusesCurrentIRCMembership() async throws {
    let client = client()
    let pending = Task { try await client.join(to: channel) }
    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    await acknowledge(socket)
    try await pending.value
    #expect(await client.chatState.reader == .ready)
    #expect(await client.chatState.channels[channel.id]?.status == .ready)

    let other = ChatChannel(id: "456", login: "other")
    let additional = Task { try await client.join(to: other) }
    await socket.waitForSent("JOIN #other")
    await socket.simulateIncoming(.string("@room-id=456 :tmi.twitch.tv ROOMSTATE #other"))
    try await additional.value
    try await client.partAndRejoinForTesting(channel)
    try await client.join(to: channel)
    #expect(await socket.sentCount(prefix: "JOIN #swift") == 1)
    #expect(await session.taskCount() == 1)
    await client.shutdownChat()
  }
}

extension TwitchClient {
  fileprivate func partAndRejoinForTesting(_ channel: ChatChannel) throws {
    part(from: channel)
    try requestJoin(to: channel)
  }

  fileprivate func partAndShutdownForTesting(_ channel: ChatChannel) {
    part(from: channel)
    chat.shutdownChat()
  }

  fileprivate var chatReadinessWaiterCount: Int {
    chat.memberships.values.reduce(0) { $0 + $1.readinessWaiters.count }
  }

  internal var moderationPrefillTask: Task<Void, Never>? { chat.prefill }
}
