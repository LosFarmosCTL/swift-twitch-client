import Foundation
import Testing

@testable import Twitch

extension EventSubSubscription {
  static func mock(version: String = "1") -> EventSubSubscription<MockEvent> {
    .init(type: "mock", version: version, condition: [:])
  }
}

struct MockEvent: Event {
  let decodingID: UUID

  private enum CodingKeys: CodingKey {}

  init(from decoder: any Decoder) throws {
    _ = try decoder.container(keyedBy: CodingKeys.self)
    decodingID = UUID()
  }
}

@Suite("General EventSub Tests")
struct WebSocketClientTests {
  let twitch: TwitchClient
  let session: MockNetworkSession = MockNetworkSession()

  init() async {
    self.twitch = TwitchClient(
      credentials: .init(accessToken: "", clientID: "", userID: "", userLogin: ""),
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

  @Test("Client delivers matching notifications after dropping invalid frames")
  func testEventSubEvents() async throws {
    await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let stream = try await twitch.eventStream(for: .mock())

    let valid = MockedMessages.mockEventMessage
    let mismatches = [
      valid.replacingOccurrences(
        of: #""subscription_type": "mock""#, with: #""subscription_type": "other""#),
      valid.replacingOccurrences(
        of: #""subscription_version": "1""#, with: #""subscription_version": "2""#),
      valid.replacingOccurrences(of: #""mock""#, with: #""other""#),
      MockedMessages.mockVersion2EventMessage,
    ]
    for (index, frame) in mismatches.enumerated() {
      await session.simulateIncoming(
        .string(MockedMessages.customized(frame, messageID: "invalid-\(index)")))
    }
    await session.simulateIncoming(
      .string(valid.replacingOccurrences(of: #""event": {}"#, with: #""event": null"#)))
    await session.simulateIncoming(.string(valid))
    await session.simulateIncoming(.string(MockedMessages.customized(valid, messageID: "next")))

    var iter = stream.makeAsyncIterator()
    let message = try #require(try await iter.next())
    #expect(message.messageID == MockedMessages.defaultEventMessageID)
    let next = try #require(try await iter.next())
    #expect(next.messageID == "next")
    await twitch.resetEventSub()
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
    await task.waitForCancellation()
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

    let secondStream = try await twitch.eventStream(for: .mock(version: "2"))

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
          MockedMessages.mockVersion2EventMessage,
          messageID: "secondary-event-message-id",
          subscriptionID: secondSubscriptionID)))

    var secondIter = secondStream.makeAsyncIterator()
    let message = try await secondIter.next()
    _ = try #require(message)
  }

  @Test(
    "A failed replacement leaves the old socket open until a retry is ready",
    .timeLimit(.minutes(1)))
  func failedReplacementKeepsOldSocket() async throws {
    await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let stream = try await twitch.eventStream(for: .mock())
    let old = await session.waitForTask(at: 0)
    await old.simulateIncoming(.string(MockedMessages.mockReconnectMessage))

    let failed = await session.waitForTask(at: 1)
    #expect(failed.url.absoluteString == "wss://eventsub.wss.twitch.tv/reconnect")
    await failed.simulateError(URLError(.networkConnectionLost))
    let retry = await session.waitForTask(at: 2)
    #expect(retry.url.absoluteString == "wss://eventsub.wss.twitch.tv/reconnect")
    #expect(await failed.didCancel)
    #expect(await !old.didCancel)

    await old.simulateIncoming(.string(MockedMessages.mockEventMessage))
    var iterator = stream.makeAsyncIterator()
    let notification = try #require(try await iterator.next())
    #expect(notification.messageID == MockedMessages.defaultEventMessageID)

    await retry.simulateIncoming(.string(MockedMessages.welcomeMessage))
    await old.waitForCancellation()
    #expect(await !retry.didCancel)
    await twitch.resetEventSub()
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
    await task.waitForCancellation()
    #expect(await task.didCancel)
  }

  @Test("Client reuses one websocket for parallel initial subscriptions")
  func testParallelInitialSubscriptionsReuseOneWebSocket() async throws {
    await session.simulateIncoming(.string(MockedMessages.welcomeMessage), queue: true)

    let streams = try await withThrowingTaskGroup(
      of: AsyncThrowingStream<EventSubNotification<MockEvent>, any Error>.self
    ) { group in
      for _ in 0..<10 {
        group.addTask {
          try await twitch.eventStream(for: .mock())
        }
      }

      var streams: [AsyncThrowingStream<EventSubNotification<MockEvent>, any Error>] = []
      for try await stream in group {
        streams.append(stream)
      }

      return streams
    }

    #expect(await session.taskCount() == 1)
    #expect(await session.requestCount() == 1)
    #expect(streams.count == 10)
    await twitch.resetEventSub()
  }
}
