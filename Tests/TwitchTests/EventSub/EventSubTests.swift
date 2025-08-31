import Foundation
import Testing

@testable import Twitch

extension EventSubSubscription where EventNotification == MockEvent {
  public static func mock(version: String = "1") -> Self {
    .init(type: EventType.mock.rawValue, version: version, condition: [:])
  }
}

@Suite("General EventSub Tests")
struct WebSocketClientTests {
  let twitch: TwitchClient
  let mockingURLSession: MockNetworkSession
  let mockingWebSocketTask: MockWebSocketTask

  init() async {
    self.mockingWebSocketTask = MockWebSocketTask()
    self.mockingURLSession = MockNetworkSession(webSocketTask: self.mockingWebSocketTask)

    self.twitch = TwitchClient(
      authentication: .init(oAuth: "", clientID: "", userID: "", userLogin: ""),
      network: mockingURLSession)

    let url = URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions")!
    await mockingURLSession.stub(
      url: url, method: "POST",
      status: 200, headers: ["Content-Type": "application/json"],
      body: MockedMessages.mockEventSubSubscription)
  }

  @Test("Client creates WebSocket task and EventSub subscription")
  func testEventSubSetup() async throws {
    try await confirmation("Should create subscription", expectedCount: 1) { confirm in
      await mockingURLSession.onRequest { _ in
        confirm()
      }

      await mockingWebSocketTask.simulateIncoming(.string(MockedMessages.welcomeMessage))
      _ = try await twitch.eventStream(for: .mock())
    }

    #expect(await mockingWebSocketTask.didResume)
    #expect(await mockingWebSocketTask.sentMessages.count == 0)
  }

  @Test("Client receives EventSub Event messages")
  func testEventSubEvents() async throws {
    await mockingWebSocketTask.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let stream = try await twitch.eventStream(for: .mock())

    await mockingWebSocketTask.simulateIncoming(
      .string(MockedMessages.mockEventMessage))

    var iter = stream.makeAsyncIterator()
    let message = try await iter.next()

    _ = try #require(message)
  }

  @Test("Client disconnects without keepalive")
  func testEventSubDisconnect() async throws {
    await mockingWebSocketTask.simulateIncoming(
      .string(MockedMessages.welcomeMessage1SecondKeepalive))

    let stream = try await twitch.eventStream(for: .mock())

    var iter = stream.makeAsyncIterator()
    let error = await #expect(
      throws: EventSubError.self,
      "Should disconnect without keepalive message"
    ) { _ = try await iter.next() }

    #expect({ if case .timedOut = error { true } else { false } }())
    #expect(await mockingWebSocketTask.didCancel)
  }

  @Test("Client disconnects on revocation message")
  func testEventSubDisconnectOnRevocation() async throws {
    await mockingWebSocketTask.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let stream = try await twitch.eventStream(for: .mock())

    await mockingWebSocketTask.simulateIncoming(
      .string(MockedMessages.mockRevocationMessage))

    var iter = stream.makeAsyncIterator()
    let error = await #expect(
      throws: EventSubError.self,
      "Should disconnect on revocation message"
    ) { _ = try await iter.next() }

    #expect({ if case .revocation = error { true } else { false } }())
    #expect(await !mockingWebSocketTask.didCancel)
  }

  @Test("Client reconnects on reconnection message")
  func testEventSubReconnect() async throws {
    await mockingWebSocketTask.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let stream = try await twitch.eventStream(for: .mock())

    await mockingWebSocketTask.simulateIncoming(
      .string(MockedMessages.mockReconnectMessage))

    await mockingWebSocketTask.simulateIncoming(.string(MockedMessages.welcomeMessage))
    await mockingWebSocketTask.simulateIncoming(.string(MockedMessages.mockEventMessage))

    var iter = stream.makeAsyncIterator()
    _ = try await iter.next()

    #expect(await mockingWebSocketTask.didCancel)
  }

  @Test("Client throws error on disconnect")
  func testEventSubDiconnect() async throws {
    await mockingWebSocketTask.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let stream = try await twitch.eventStream(for: .mock())

    await mockingWebSocketTask.simulateError(WebSocketError.unsupportedDataReceived)

    var iter = stream.makeAsyncIterator()
    let error = await #expect(
      throws: EventSubError.self,
      "Should disconnect on revocation message"
    ) { _ = try await iter.next() }

    #expect({ if case .disconnected = error { true } else { false } }())
    #expect(await mockingWebSocketTask.didCancel)
  }
}
