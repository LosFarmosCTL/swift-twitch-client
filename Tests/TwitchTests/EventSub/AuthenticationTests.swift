import Foundation
import Testing

@testable import Twitch

struct EventSubAuthenticationTests {
  private let app = TwitchCredentials.app(accessToken: "app-token", clientID: "client-id")
  private let user = TwitchCredentials(
    accessToken: "user-token", clientID: "client-id", userID: "1234", userLogin: "user")

  @Test(arguments: [
    EventSubTransport.webSocket(id: "session"),
    .webhook(callback: "https://example.com/events", secret: "webhook-secret"),
    .conduit(id: "conduit"),
  ])
  func rawSubscriptionUsesTransportTokenRequirement(transport: EventSubTransport)
    async throws
  {
    let usesUser: Bool
    if case .webSocket = transport { usesUser = true } else { usesUser = false }
    let harness = HelixTestHarness(credentials: usesUser ? user : app)
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions"))
    await harness.session.stub(
      url: url, method: "POST", body: MockedData.createEventSubSubscriptionJSON)
    _ =
      (try await harness.twitch.helix(
        for: .createEventSubSubscription(
          using: transport, for: .streamOnline(broadcasterID: "channel")))).value
    #expect(
      await harness.session.lastRequest()?.value(forHTTPHeaderField: "Authorization")
        == (usesUser ? "Bearer user-token" : "Bearer app-token"))
    #expect(await harness.session.taskCount() == 0)

    let wrong = HelixTestHarness(credentials: usesUser ? app : user)
    let error = await #expect(throws: HelixError.self) {
      _ =
        (try await wrong.twitch.helix(
          for: .createEventSubSubscription(
            using: transport, for: .streamOnline(broadcasterID: "channel")))).value
    }
    if case .authenticationError(let reason) = error {
      #expect(reason == (usesUser ? .userAccessTokenRequired : .appAccessTokenRequired))
    } else {
      Issue.record("Expected a transport-specific authentication error")
    }
    #expect(await wrong.session.requestCount() == 0)
  }

  @Test(arguments: [true, false])
  func streamAndListenerRequireUserCredentials(usesAppToken: Bool) async {
    let harness = HelixTestHarness(credentials: usesAppToken ? app : nil)
    await #expect(throws: TwitchAuthenticationError.userAccessTokenRequired) {
      _ = try await harness.twitch.eventStream(
        for: .streamOnline(broadcasterID: "channel"))
    }
    await #expect(throws: TwitchAuthenticationError.userAccessTokenRequired) {
      _ = try await harness.twitch.eventListener(
        for: .streamOnline(broadcasterID: "channel")
      ) { _ in }
    }
    #expect(await harness.session.taskCount() == 0)
    #expect(await harness.session.requestCount() == 0)
  }

  #if canImport(Combine)
    @Test(arguments: [true, false])
    func publisherRequiresUserCredentialsOnDemand(usesAppToken: Bool) async throws {
      let harness = HelixTestHarness(credentials: usesAppToken ? app : nil)
      let failures = AsyncStream<any Error>.makeStream()
      let publisher = harness.twitch.eventPublisher(
        for: .streamOnline(broadcasterID: "channel"))
      #expect(await harness.session.taskCount() == 0)
      let handle = publisher.sink(
        receiveCompletion: {
          if case .failure(let error) = $0 { failures.continuation.yield(error) }
        },
        receiveValue: { _ in Issue.record("WebSocket events require user credentials") })
      let error = try #require(await failures.stream.first { _ in true })
      #expect(error as? TwitchAuthenticationError == .userAccessTokenRequired)
      #expect(await harness.session.taskCount() == 0)
      #expect(await harness.session.requestCount() == 0)
      withExtendedLifetime(handle) {}
    }
  #endif

  @Test(.timeLimit(.minutes(1)))
  func clearingCredentialsFinishesObserversAndCleansUpWithOriginalCredentials() async throws {
    let harness = HelixTestHarness(credentials: user)
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions"))
    let initialID = MockedMessages.defaultSubscriptionID
    let pendingID = "pending-subscription"
    for id in [initialID, pendingID] {
      await harness.session.stub(
        url: url.appending(queryItems: [.init(name: "id", value: id)]),
        method: "DELETE", status: 204)
    }
    await harness.session.stub(
      url: url, method: "POST",
      body: Data(MockedMessages.mockEventSubSubscription.utf8))
    await harness.session.simulateIncoming(
      .string(MockedMessages.welcomeMessage), queue: true)
    let active = try await harness.twitch.eventStream(for: .mock())
    await harness.session.stub(
      url: url, method: "POST",
      body: Data(
        MockedMessages.customized(
          MockedMessages.mockEventSubSubscription, subscriptionID: pendingID
        ).utf8))
    let gate = AsyncTestGate()
    let deleted = AsyncStream<Void>.makeStream()
    await harness.session.onRequest { request in
      if request.httpMethod == "POST" { await gate.pause() }
      if request.httpMethod == "DELETE" { deleted.continuation.yield(()) }
    }
    let setup = Task { try await harness.twitch.eventStream(for: .mock(version: "2")) }
    await gate.waitUntilEntered()

    await harness.twitch.clearCredentials()
    #expect(await harness.session.lastTask()?.didCancel == true)
    var activeIterator = active.makeAsyncIterator()
    #expect(try await activeIterator.next() == nil)
    await gate.release()
    await #expect(throws: CancellationError.self) { _ = try await setup.value }

    var deletions = deleted.stream.makeAsyncIterator()
    _ = await deletions.next()
    _ = await deletions.next()
    let requests = await harness.session.requests()
    #expect(requests.map(\.httpMethod) == ["POST", "POST", "DELETE", "DELETE"])
    #expect(
      requests.allSatisfy {
        $0.value(forHTTPHeaderField: "Authorization") == "Bearer user-token"
          && $0.value(forHTTPHeaderField: "Client-Id") == user.clientID
      })
    let deletedQueries = requests.filter { $0.httpMethod == "DELETE" }.compactMap { $0.url?.query }
    #expect(Set(deletedQueries) == ["id=\(initialID)", "id=\(pendingID)"])
    await #expect(throws: TwitchAuthenticationError.userAccessTokenRequired) {
      _ = try await harness.twitch.eventStream(for: .mock())
    }
    #expect(await harness.session.taskCount() == 1)

    await harness.twitch.switchCredentials(to: user)
    await harness.session.onRequest { _ in }
    await harness.session.simulateIncoming(
      .string(MockedMessages.welcomeMessage), queue: true)
    _ = try await harness.twitch.eventStream(for: .mock())
    #expect(await harness.session.taskCount() == 2)
    await harness.twitch.resetEventSub()
  }

  @Test(.timeLimit(.minutes(1)))
  func credentialSwitchCancelsPendingHandshake() async throws {
    let harness = HelixTestHarness(credentials: user)
    let coordinator = await harness.twitch.eventSubClient
    let originalRevision = await harness.twitch.eventSubRevision
    let setup = Task { try await harness.twitch.eventStream(for: .mock()) }
    let socket = await harness.session.waitForTask(at: 0)
    await harness.twitch.switchCredentials(to: app)
    await #expect(throws: CancellationError.self) { _ = try await setup.value }
    #expect(await socket.didCancel)
    await #expect(throws: CancellationError.self) {
      _ = try await coordinator.reserveSubscriptionSlot(revision: originalRevision)
    }
    #expect(await harness.session.taskCount() == 1)
    #expect(await harness.session.requestCount() == 0)
  }
}
