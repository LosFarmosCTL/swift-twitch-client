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

  @Test
  func appStreamAndListenerRejectBeforeOpeningSocket() async {
    let harness = HelixTestHarness(credentials: app)
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
    @Test
    func appPublisherRejectsBeforeOpeningSocket() async {
      let harness = HelixTestHarness(credentials: app)
      await #expect(throws: TwitchAuthenticationError.userAccessTokenRequired) {
        _ = try await harness.twitch.eventPublisher(
          for: .streamOnline(broadcasterID: "channel"))
      }
      #expect(await harness.session.taskCount() == 0)
    }
  #endif

  @Test(.timeLimit(.minutes(1)))
  func credentialSwitchDuringHTTPSetupCleansUpWithOriginalToken() async throws {
    let harness = HelixTestHarness(credentials: user)
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions"))
    let deleteURL = url.appending(queryItems: [
      URLQueryItem(name: "id", value: MockedMessages.defaultSubscriptionID)
    ])
    await harness.session.stub(
      url: url, method: "POST",
      body: Data(MockedMessages.mockEventSubSubscription.utf8))
    await harness.session.stub(url: deleteURL, method: "DELETE", status: 204)
    let gate = SubscriptionRequestGate()
    await harness.session.onRequest { request in
      if request.httpMethod == "POST" { await gate.pause() }
    }
    await harness.session.simulateIncoming(
      .string(MockedMessages.welcomeMessage), queue: true)
    let setup = Task { try await harness.twitch.eventStream(for: .mock()) }
    await gate.waitUntilEntered()

    await harness.twitch.switchCredentials(to: app)
    await gate.release()
    await #expect(throws: CancellationError.self) { _ = try await setup.value }

    let requests = await harness.session.requests()
    #expect(requests.map(\.httpMethod) == ["POST", "DELETE"])
    #expect(
      requests.allSatisfy {
        $0.value(forHTTPHeaderField: "Authorization") == "Bearer user-token"
      })
    #expect(await harness.session.lastTask()?.didCancel == true)
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
    let originalContext = await harness.twitch.eventSubClient
    let setup = Task { try await harness.twitch.eventStream(for: .mock()) }
    let socket = await harness.session.waitForTask(at: 0)
    await harness.twitch.switchCredentials(to: app)
    await #expect(throws: CancellationError.self) { _ = try await setup.value }
    #expect(await socket.didCancel)
    await #expect(throws: CancellationError.self) {
      _ = try await originalContext.reserveWebSocketSessionID()
    }
    #expect(await harness.session.taskCount() == 1)
    #expect(await harness.session.requestCount() == 0)
  }
}

private actor SubscriptionRequestGate {
  private var entered = false
  private var entryWaiter: CheckedContinuation<Void, Never>?
  private var releaseWaiter: CheckedContinuation<Void, Never>?

  func pause() async {
    entered = true
    entryWaiter?.resume()
    entryWaiter = nil
    await withCheckedContinuation { releaseWaiter = $0 }
  }

  func waitUntilEntered() async {
    if entered { return }
    await withCheckedContinuation { entryWaiter = $0 }
  }

  func release() {
    releaseWaiter?.resume()
    releaseWaiter = nil
  }
}
