import Foundation
import Testing

@testable import Twitch

extension EventSubSubscription {
  public static func mock(version: String = "1") -> EventSubSubscription<MockEvent> {
    .init(type: EventType.mock.rawValue, version: version, condition: [:])
  }
}

@Suite("General EventSub Tests")
struct WebSocketClientTests {
  let twitch: TwitchClient
  let session: MockNetworkSession = MockNetworkSession()

  init() async {
    self.twitch = TwitchClient(
      authentication: .init(oAuth: "", clientID: "", userID: "", userLogin: ""),
      network: session)

    let url = URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions")!
    await session.stub(
      url: url, method: "POST",
      status: 200, headers: ["Content-Type": "application/json"],
      body: MockedMessages.mockEventSubSubscription.data(using: .utf8)!)
  }

  @Test("Client creates WebSocket task and EventSub subscription")
  func testEventSubSetup() async throws {
    try await confirmation("Should create subscription", expectedCount: 1) { confirm in
      await session.onRequest { request in
        guard request.httpMethod == "POST" else { return }

        let body = try? await twitch.decoder.decode(
          CreateEventSubRequestBody.self, from: request.httpBody ?? Data())

        #expect(body?.type == "mock")
        #expect(body?.version == "1")

        #expect(body?.condition.count == 0)
        #expect(body?.transport.method == "websocket")
        #expect(body?.transport.sessionID == "111111111111111111111111111111111111")
        #expect(body?.transport.callback == nil)
        #expect(body?.transport.secret == nil)
        #expect(body?.transport.conduitID == nil)

        confirm()
      }

      await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
      _ = try await twitch.eventStream(for: .mock())
    }

    let task = try #require(await session.lastTask())
    #expect(await task.didResume)
    #expect(await task.sentMessages.count == 0)
  }

  @Test("Client deletes EventSub subscription on stream termination V2")
  func testEventSubDeleteOnTerminationV2() async throws {
    let subscriptionID = MockedMessages.defaultSubscriptionID
    var components = URLComponents(
      string: "https://api.twitch.tv/helix/eventsub/subscriptions")
    components?.queryItems = [URLQueryItem(name: "id", value: subscriptionID)]
    let deleteURL = try #require(components?.url)
    await session.stub(url: deleteURL, method: "DELETE", status: 204)

    try await confirmation("Should delete subscription", expectedCount: 1) { confirm in
      let deleteSeen = AsyncStream<Void>.makeStream()
      await session.onRequest { request in
        guard request.httpMethod == "DELETE" else { return }
        #expect(request.url == deleteURL)
        confirm()
        deleteSeen.continuation.finish()
      }
      await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
      let stream = try await twitch.eventStream(for: .mock())

      let consumeTask = Task { for try await _ in stream { break } }
      consumeTask.cancel()

      _ = await deleteSeen.stream.first { _ in true }
    }
  }

  @Test("Client receives EventSub Event messages")
  func testEventSubEvents() async throws {
    await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let stream = try await twitch.eventStream(for: .mock())

    await session.simulateIncoming(
      .string(MockedMessages.mockEventMessage))

    var iter = stream.makeAsyncIterator()
    let message = try await iter.next()

    _ = try #require(message)
  }

  @Test("Client disconnects without keepalive")
  func testEventSubDisconnect() async throws {
    await session.simulateIncoming(
      .string(MockedMessages.welcomeMessage1SecondKeepalive))

    let stream = try await twitch.eventStream(for: .mock())

    var iter = stream.makeAsyncIterator()
    let error = await #expect(
      throws: EventSubError.self,
      "Should disconnect without keepalive message"
    ) { _ = try await iter.next() }

    #expect({ if case .timedOut = error { true } else { false } }())

    let task = try #require(await session.lastTask())
    #expect(await task.didCancel)
  }

  @Test("Client disconnects on revocation message")
  func testEventSubDisconnectOnRevocation() async throws {
    await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let stream = try await twitch.eventStream(for: .mock())

    await session.simulateIncoming(
      .string(MockedMessages.mockRevocationMessage))

    var iter = stream.makeAsyncIterator()
    let error = await #expect(
      throws: EventSubError.self,
      "Should disconnect on revocation message"
    ) { _ = try await iter.next() }

    #expect({ if case .revocation = error { true } else { false } }())

    let task = try #require(await session.lastTask())
    #expect(await task.didCancel)
  }

  @Test("Client keeps websocket open when one of multiple subscriptions is revoked")
  func testEventSubRevocationKeepsSharedConnectionAlive() async throws {
    let secondSubscriptionID = "22222222-2222-2222-2222-222222222222"
    let url = URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions")!

    await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let firstStream = try await twitch.eventStream(for: .mock())

    await session.stub(
      url: url,
      method: "POST",
      status: 200,
      headers: ["Content-Type": "application/json"],
      body: MockedMessages.customized(
        MockedMessages.mockEventSubSubscription,
        subscriptionID: secondSubscriptionID
      ).data(using: .utf8)!)

    let secondStream = try await twitch.eventStream(for: .mock())

    await session.simulateIncoming(
      .string(MockedMessages.mockRevocationMessage))

    var firstIter = firstStream.makeAsyncIterator()
    let error = await #expect(
      throws: EventSubError.self,
      "Should only revoke the targeted subscription"
    ) { _ = try await firstIter.next() }

    #expect({ if case .revocation = error { true } else { false } }())

    let task = try #require(await session.lastTask())
    #expect(await !task.didCancel)

    await session.simulateIncoming(
      .string(
        MockedMessages.customized(
          MockedMessages.mockEventMessage,
          messageID: "secondary-event-message-id",
          subscriptionID: secondSubscriptionID)))

    var secondIter = secondStream.makeAsyncIterator()
    let message = try await secondIter.next()
    _ = try #require(message)
  }

  @Test("Client reconnects on reconnection message")
  func testEventSubReconnect() async throws {
    await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let stream = try await twitch.eventStream(for: .mock())

    await session.simulateIncoming(.string(MockedMessages.welcomeMessage), queue: true)
    await session.simulateIncoming(.string(MockedMessages.mockEventMessage), queue: true)

    await session.simulateIncoming(
      .string(MockedMessages.mockReconnectMessage))

    var iter = stream.makeAsyncIterator()
    _ = try await iter.next()

    let oldTask = try #require(await session.task(at: 0))
    #expect(await oldTask.didCancel)

    let newTask = try #require(await session.task(at: 1))
    #expect(newTask.url.absoluteString == "wss://eventsub.wss.twitch.tv/reconnect")
  }

  @Test("Client throws error on disconnect")
  func testEventSubDiconnect() async throws {
    await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let stream = try await twitch.eventStream(for: .mock())

    await session.simulateError(WebSocketError.unsupportedDataReceived)

    var iter = stream.makeAsyncIterator()
    let error = await #expect(
      throws: EventSubError.self,
      "Should disconnect on revocation message"
    ) { _ = try await iter.next() }

    #expect({ if case .disconnected = error { true } else { false } }())

    let task = try #require(await session.lastTask())
    #expect(await task.didCancel)
  }

  @Test("Client reuses one websocket for parallel initial subscriptions")
  func testParallelInitialSubscriptionsReuseOneWebsocket() async throws {
    await session.simulateIncoming(.string(MockedMessages.welcomeMessage), queue: true)

    _ = try await withThrowingTaskGroup(
      of: AsyncThrowingStream<MockEvent, any Error>.self
    ) { group in
      for _ in 0..<10 {
        group.addTask {
          try await twitch.eventStream(for: .mock())
        }
      }

      var streams: [AsyncThrowingStream<MockEvent, any Error>] = []
      for try await stream in group {
        streams.append(stream)
      }

      return streams
    }

    #expect(await session.taskCount() == 1)
  }
}
