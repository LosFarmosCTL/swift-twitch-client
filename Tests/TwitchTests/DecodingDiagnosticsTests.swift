import Foundation
import Testing

@testable import Twitch

@Suite(.timeLimit(.minutes(1)))
struct DecodingDiagnosticsTests {
  private let url = URL(string: "https://api.twitch.tv/helix/diagnostics")!
  private let endpoint = HelixEndpoint<[Item]>(
    method: "GET", path: "diagnostics", authentication: .either,
    responseType: Item.self, makeResponse: { $0.data })

  @Test(arguments: [
    (body: #"{"data":[{"count":"private input"}]}"#, path: "data[0].count"),
    (body: #"{"data":{}}"#, path: "data.count"),
  ])
  func helixPreservesNestedDecodingFailures(input: (body: String, path: String)) async {
    await confirmation { reported in
      let harness = HelixTestHarness(
        diagnostics: .init { diagnostic in
          #expect(diagnostic.source == .helix)
          #expect(diagnostic.stage == .response)
          #expect(diagnostic.details.pathDescription == input.path)
          reported()
        })
      let data = Data(input.body.utf8)
      await harness.session.stub(url: url, body: data)

      let error = await #expect(throws: HelixError.self) {
        try await harness.twitch.helix(for: endpoint)
      }
      guard case .parsingResponseFailed(let failure) = error else {
        Issue.record("Expected a response parsing failure")
        return
      }
      #expect(failure.responseData == data)
      #expect(failure.details.pathDescription == input.path)
      switch failure.underlyingError {
      case DecodingError.typeMismatch where input.path == "data[0].count":
        #expect(failure.details.kind == .typeMismatch)
        #expect(failure.details.codingPath == [.key("data"), .index(0), .key("count")])
      case DecodingError.keyNotFound(let key, _) where input.path == "data.count":
        #expect(key.stringValue == "count")
        #expect(failure.details.kind == .keyNotFound)
      default:
        Issue.record("Expected the original nested decoding error")
      }
    }
  }

  @Test
  func recoveredShapesAreSilentAndMalformedPaginationRemainsNonfatal() async throws {
    try await confirmation { reported in
      let harness = HelixTestHarness(
        diagnostics: .init { diagnostic in
          #expect(diagnostic.stage == .pagination)
          #expect(diagnostic.details.pathDescription == "pagination.cursor")
          reported()
        })
      let endpoint = HelixEndpoint<String?>(
        method: "GET", path: "diagnostics", authentication: .either,
        responseType: Item.self, makeResponse: { $0.pagination?.cursor })

      await harness.session.stub(
        url: url, body: Data(#"{"data":{"count":1},"pagination":"next"}"#.utf8))
      let recovered = try await harness.twitch.helix(for: endpoint)
      #expect(recovered.value == "next")

      await harness.session.stub(
        url: url, body: Data(#"{"data":[{"count":1}],"pagination":{"cursor":12}}"#.utf8))
      let malformed = try await harness.twitch.helix(for: endpoint)
      #expect(malformed.value == nil)
    }
  }

  @Test(arguments: [400, 429])
  func malformedErrorBodiesPreserveTheHTTPOutcome(status: Int) async {
    await confirmation { reported in
      let harness = HelixTestHarness(
        diagnostics: .init { diagnostic in
          #expect(diagnostic.source == .helix)
          #expect(diagnostic.stage == .errorResponse)
          #expect(diagnostic.details.kind == .dataCorrupted)
          #expect(diagnostic.metadata?.statusCode == status)
          reported()
        })
      let body = Data("invalid JSON".utf8)
      await harness.session.stub(url: url, status: status, body: body)

      let error = await #expect(throws: HelixError.self) {
        try await harness.twitch.helix(for: endpoint)
      }
      switch error {
      case .parsingErrorFailed(let actualStatus, let failure) where status == 400:
        #expect(actualStatus == status)
        #expect(failure.underlyingError is DecodingError)
        #expect(failure.responseData == body)
      case .rateLimited(let limit) where status == 429:
        #expect(limit.responseData == body)
      default:
        Issue.record("Unexpected HTTP outcome: \(String(describing: error))")
      }
    }
  }

  @Test
  func networkingAndCancellationDoNotReportDecodingFailures() async {
    await confirmation(expectedCount: 0) { reported in
      let harness = HelixTestHarness(diagnostics: .init { _ in reported() })

      await harness.session.stub(url: url, error: URLError(.notConnectedToInternet))
      let error = await #expect(throws: HelixError.self) {
        try await harness.twitch.helix(for: endpoint)
      }
      guard case .networkError = error else {
        Issue.record("Expected a network error")
        return
      }

      await harness.session.stub(url: url, error: URLError(.cancelled))
      await #expect(throws: CancellationError.self) {
        try await harness.twitch.helix(for: endpoint)
      }

      let cancellingEndpoint = HelixEndpoint<Void>(
        method: "GET", path: "diagnostics", authentication: .either,
        responseType: CancellingItem.self, makeResponse: { _ in })
      await harness.session.stub(url: url, body: Data(#"{"data":[{}]}"#.utf8))
      await #expect(throws: CancellationError.self) {
        try await harness.twitch.helix(for: cancellingEndpoint)
      }
    }
  }

  @Test
  func internalHelixRequestsUseClientDiagnostics() async throws {
    let reports = AsyncStream<TwitchDecodingDiagnostic>.makeStream()
    let harness = HelixTestHarness(diagnostics: .init { reports.continuation.yield($0) })
    let users = URL(string: "https://api.twitch.tv/helix/users?id=123")!
    let subscriptions = URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions")!
    let body = Data(#"{"data":[{}]}"#.utf8)
    await harness.session.stub(url: users, body: body)
    await harness.session.stub(url: subscriptions, method: "POST", body: body)
    await harness.session.simulateIncoming(.string(MockedMessages.welcomeMessage))

    await #expect(throws: HelixError.self) { try await harness.twitch.join(channelID: "123") }
    await #expect(throws: HelixError.self) { try await harness.twitch.eventStream(for: .mock()) }

    await harness.twitch.resetEventSub()
    reports.continuation.finish()
    var paths: [String] = []
    for await report in reports.stream {
      #expect(report.source == .helix)
      #expect(report.stage == .response)
      paths.append(try #require(report.requestPath))
    }
    #expect(paths == ["users", "eventsub/subscriptions"])
  }

  @Test
  func malformedEventSubFramesReportAndAValidReplayStillArrives() async throws {
    let reports = AsyncStream<TwitchDecodingDiagnostic>.makeStream()
    let harness = HelixTestHarness(diagnostics: .init { reports.continuation.yield($0) })
    var streamReports = await harness.twitch.decodingDiagnostics().makeAsyncIterator()
    let broadcasterID = "456"
    let subscription = EventSubSubscription<MockEvent>(
      type: "mock", version: "1", condition: ["broadcaster_user_id": broadcasterID])
    await harness.session.stub(
      url: URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions")!, method: "POST",
      body: Data(MockedMessages.mockEventSubSubscription.utf8))
    await harness.session.simulateIncoming(.string(#"{"metadata":{"message_type":12}}"#))
    await harness.session.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let stream = try await harness.twitch.eventStream(for: subscription)
    var iterator = stream.makeAsyncIterator()
    let valid = MockedMessages.mockEventMessage.replacingOccurrences(
      of: #""condition": {}"#, with: #""condition": {"broadcaster_user_id": "\#(broadcasterID)"}"#)
    await harness.session.simulateIncoming(
      .string(valid.replacingOccurrences(of: #""event": {}"#, with: #""event": null"#)))
    await harness.session.simulateIncoming(.string(valid))
    let delivered = try #require(try await iterator.next())
    #expect(delivered.messageID == MockedMessages.defaultEventMessageID)

    await harness.session.simulateIncoming(.string(MockedMessages.mockRevocationMessage))
    let error = await #expect(throws: EventSubError.self) { try await iterator.next() }
    guard case .revocation = error else {
      Issue.record("Expected a revocation to finish the stream")
      return
    }
    await harness.twitch.resetEventSub()
    reports.continuation.finish()

    let diagnostics = await reports.stream.reduce(into: [TwitchDecodingDiagnostic]()) {
      $0.append($1)
    }
    try #require(diagnostics.map(\.stage) == [.eventSubMessage, .eventSubPayload])
    #expect(diagnostics.allSatisfy { $0.source == .eventSub })
    for diagnostic in diagnostics { #expect(await streamReports.next() == diagnostic) }

    #expect(diagnostics.map { $0.eventSubMetadata?.channelID } == [nil, broadcasterID])
    #expect(diagnostics[1].details.pathDescription == "payload.event")
    #expect(diagnostics[1].eventSubMetadata?.messageID == delivered.messageID)
  }

  @Test
  func diagnosticStreamsAreLiveBoundedAndIndependent() async throws {
    let credentials = TwitchCredentials.app(accessToken: "token", clientID: "client")
    let network = MockNetworkSession()
    let callbacks = AsyncStream<TwitchDecodingDiagnostic>.makeStream()
    let configuration = TwitchDiagnostics { callbacks.continuation.yield($0) }
    var client: TwitchClient? = TwitchClient(
      credentials: credentials, network: network, diagnostics: configuration)
    var otherClient: TwitchClient? = TwitchClient(
      credentials: credentials, network: network, diagnostics: configuration)

    let reports = try #require(await client?.decodingDiagnostics())
    let otherReports = try #require(await otherClient?.decodingDiagnostics())
    let cancelled = try #require(await client?.decodingDiagnostics())
    let consumer = Task {
      var iterator = cancelled.makeAsyncIterator()
      return await iterator.next()
    }
    consumer.cancel()
    #expect(await consumer.value == nil)

    for status in 400..<465 {
      if status == 432 {
        await client?.resetEventSub()
        await client?.switchCredentials(to: .app(accessToken: "replacement", clientID: "client"))
      }
      await network.stub(url: url, status: status, body: Data("invalid JSON".utf8))
      await #expect(throws: HelixError.self) { try await client?.helix(for: endpoint) }
    }
    let lateReports = try #require(await client?.decodingDiagnostics())
    client = nil
    otherClient = nil
    callbacks.continuation.finish()

    let logged = await collect(callbacks.stream)
    #expect(logged.compactMap { $0.metadata?.statusCode } == Array(400..<465))
    #expect(await collect(reports) == Array(logged.suffix(64)))
    for stream in [cancelled, otherReports, lateReports] {
      var iterator = stream.makeAsyncIterator()
      #expect(await iterator.next() == nil)
    }
  }

  private func collect(_ stream: AsyncStream<TwitchDecodingDiagnostic>) async
    -> [TwitchDecodingDiagnostic]
  {
    await stream.reduce(into: []) { $0.append($1) }
  }
}

private struct Item: Decodable, Sendable {
  let count: Int
}

private struct CancellingItem: Decodable, Sendable {
  init(from decoder: any Decoder) throws { throw CancellationError() }
}
