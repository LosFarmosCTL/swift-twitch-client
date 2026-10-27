import Foundation
import Testing

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@Suite(.timeLimit(.minutes(1)))
struct HelixRateLimitTests {
  private let harness = HelixTestHarness()
  private let url = URL(string: "https://api.twitch.tv/helix/metadata")!
  private let body = Data(#"{"data":["value"]}"#.utf8)
  private let headers = [
    "Ratelimit-Limit": "800", "Ratelimit-Remaining": "0",
    "Ratelimit-Reset": "1900000000",
  ]

  @Test
  func successfulResponsesExposeMetadataWithoutDelayingLaterRequests() async throws {
    await harness.session.stub(url: url, headers: headers, body: body)
    for _ in 0..<2 {
      let response = try await harness.twitch.helix(
        for: .custom(method: "GET", path: "metadata"))
      #expect(response.value == "value")
      #expect(response.metadata.statusCode == 200)
      #expect(response.metadata.rateLimit?.limit == 800)
      #expect(response.metadata.rateLimit?.remaining == 0)
      #expect(
        response.metadata.rateLimit?.resetAt == Date(timeIntervalSince1970: 1_900_000_000)
      )
    }
    #expect(await harness.session.requestCount() == 2)
  }

  @Test
  func rawAndEmptyResponsesAndCallbacksExposeTheSameMetadata() async throws {
    await harness.session.stub(url: url, headers: headers, body: body)
    let raw: HelixEndpoint<Data, EmptyResponse, HelixEndpointResponseTypes.Raw> = .init(
      method: "GET", path: "metadata", authentication: .either, makeRawResponse: { $0 })
    let response = try await harness.twitch.helix(for: raw)
    #expect(response.value == body)
    #expect(response.metadata.rateLimit?.remaining == 0)

    await harness.session.stub(url: url, method: "DELETE", status: 204, headers: headers)
    let empty:
      HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> =
        .init(method: "DELETE", path: "metadata", authentication: .either)
    let deleted = try await harness.twitch.helix(for: empty)
    #expect(deleted.metadata.statusCode == 204)
    #expect(deleted.metadata.rateLimit?.limit == 800)

    let result: Result<HelixResponse<Void>, HelixError> = await withCheckedContinuation {
      continuation in
      harness.twitch.helixTask(for: empty) { continuation.resume(returning: $0) }
    }
    #expect(try result.get().metadata.statusCode == 204)
    #expect(try result.get().metadata.rateLimit?.remaining == 0)
  }

  @Test(arguments: ["invalid", "-1", "99999999999999999999999999"])
  func malformedHeaderFieldsDoNotDiscardValidFieldsOrFailTheRequest(value: String)
    async throws
  {
    await harness.session.stub(
      url: url,
      headers: [
        "ratelimit-limit": "800", "RATELIMIT-REMAINING": value,
        "Ratelimit-Reset": value,
      ], body: body)
    let response = try await harness.twitch.helix(
      for: .custom(method: "GET", path: "metadata"))
    #expect(response.value == "value")
    let limit = try #require(response.metadata.rateLimit)
    #expect(limit.limit == 800)
    #expect(limit.remaining == nil)
    #expect(limit.resetAt == nil)
  }

  @Test(arguments: ["GET", "POST"], [true, false])
  func rateLimitedResponsesAreTypedAndNeverRetried(method: String, validJSON: Bool)
    async throws
  {
    let data =
      validJSON
      ? Data(#"{"error":"Too Many Requests","status":429,"message":"Slow down"}"#.utf8)
      : Data("not JSON".utf8)
    await harness.session.stub(
      url: url, method: method, status: 429, headers: headers, body: data)
    let error = await #expect(throws: HelixError.self) {
      try await harness.twitch.helix(for: .custom(method: method, path: "metadata"))
    }
    guard case .rateLimited(let info) = error else {
      Issue.record("Expected HTTP 429 to produce a rate-limit error")
      return
    }
    #expect(info.metadata.statusCode == 429)
    #expect(info.metadata.rateLimit?.remaining == 0)
    #expect(info.responseData == data)
    #expect(info.name == (validJSON ? "Too Many Requests" : nil))
    #expect(info.message == (validJSON ? "Slow down" : nil))
    #expect(await harness.session.requestCount() == 1)
  }

  @Test
  func absentHeadersRemainUnknownOnSuccessAndEmpty429Responses() async throws {
    await harness.session.stub(url: url, body: body)
    let response = try await harness.twitch.helix(
      for: .custom(method: "GET", path: "metadata"))
    #expect(response.value == "value")
    #expect(response.metadata.rateLimit == nil)

    await harness.session.stub(url: url, status: 429)
    let error = await #expect(throws: HelixError.self) {
      try await harness.twitch.helix(for: .custom(method: "GET", path: "metadata"))
    }
    guard case .rateLimited(let info) = error else {
      Issue.record("Expected HTTP 429 to remain recognizable without headers or a body")
      return
    }
    #expect(info.metadata.rateLimit == nil)
    #expect(info.responseData.isEmpty)
  }

  @Test
  func staticRequestsAndCallbacksReturnResponseMetadata() async throws {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MetadataURLProtocol.self]
    let session = URLSession(configuration: configuration)
    defer { session.invalidateAndCancel() }
    let credentials = TwitchCredentials.app(accessToken: "token", clientID: "client")
    let response = try await TwitchClient.helix(
      for: .custom(method: "GET", path: "metadata"), credentials: credentials,
      urlSession: session)
    #expect(response.value == "value")
    #expect(response.metadata.rateLimit?.remaining == 7)

    let result: Result<HelixResponse<String?>, HelixError> = await withCheckedContinuation
    {
      continuation in
      TwitchClient.helixTask(
        for: .custom(method: "GET", path: "metadata"), credentials: credentials,
        urlSession: session
      ) { continuation.resume(returning: $0) }
    }
    #expect(try result.get().value == "value")
    #expect(try result.get().metadata.rateLimit?.remaining == 7)
  }
}

private final class MetadataURLProtocol: URLProtocol {
  override static func canInit(with request: URLRequest) -> Bool { true }

  override static func canonicalRequest(for request: URLRequest) -> URLRequest { request }

  override func startLoading() {
    guard let url = request.url,
      let response = HTTPURLResponse(
        url: url, statusCode: 200, httpVersion: "HTTP/1.1",
        headerFields: ["Ratelimit-Limit": "800", "Ratelimit-Remaining": "7"])
    else {
      client?.urlProtocol(self, didFailWithError: URLError(.badURL))
      return
    }
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    client?.urlProtocol(self, didLoad: Data(#"{"data":["value"]}"#.utf8))
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}
}
