import Foundation
import Testing

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

struct HelixTests {
  private let harness = HelixTestHarness(
    credentials: .init(
      accessToken: "abcdefg",
      clientID: "123456",
      userID: "1234",
      userLogin: "user"))

  @Test
  func helixAuthentication() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/chat/badges/global"))
    await harness.session.stub(
      url: url,
      body: Data("{\"data\":[]}".utf8))

    _ = try await harness.twitch.helix(for: .getGlobalBadges())

    let request = try #require(await harness.session.lastRequest())
    #expect(request.value(forHTTPHeaderField: "Client-Id") == "123456")
    #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer abcdefg")
  }

  @Test
  func signedOutCalendarIsHeaderlessThroughAsyncAndCallbackAPIs() async throws {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [CalendarURLProtocol.self]
    let session = URLSession(configuration: configuration)
    defer { session.invalidateAndCancel() }
    let client = TwitchClient(chat: .init(), urlSession: session)
    let endpoint: HelixEndpoint<String> = .getChannelICalendar(broadcasterID: "1234")

    #expect(try await client.helix(for: endpoint).value == "BEGIN:VCALENDAR")
    let result: Result<HelixResponse<String>, HelixError> = await withCheckedContinuation {
      continuation in
      client.helixTask(for: endpoint) { continuation.resume(returning: $0) }
    }
    #expect(try result.get().value == "BEGIN:VCALENDAR")

    let protected: Result<HelixResponse<[User]>, HelixError> = await withCheckedContinuation {
      continuation in
      client.helixTask(for: .getUsers()) { continuation.resume(returning: $0) }
    }
    guard case .failure(.authenticationError(.oauthAccessTokenRequired)) = protected else {
      Issue.record("Expected the callback to fail with an OAuth requirement")
      return
    }
  }

  @Test
  func signedOutHelixRejectsProtectedRequestsBeforeBuildingParameters() async {
    let session = MockNetworkSession()
    let client = TwitchClient(credentials: nil, network: session)
    let requirements: [(HelixAuthentication, TwitchAuthenticationError)] = [
      (.user, .userAccessTokenRequired), (.app, .appAccessTokenRequired),
      (.either, .oauthAccessTokenRequired), (.extensionJWT, .extensionJWTRequired),
    ]
    for (authentication, expected) in requirements {
      let endpoint = HelixEndpoint<Void>(
        method: "POST", path: "protected", authentication: authentication,
        queryItems: { _ in
          Issue.record("Credential-dependent parameters must not be built while signed out")
          return []
        })
      let error = await #expect(throws: HelixError.self) { try await client.helix(for: endpoint) }
      guard case .authenticationError(let reason) = error else {
        Issue.record("Expected an authentication error for \(authentication)")
        continue
      }
      #expect(reason == expected)
    }
  }

  @Test
  func withJSONBody() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/test"))
    await harness.session.stub(
      url: url,
      method: "POST",
      body: Data("{\"data\":[\"forsen\"]}".utf8))

    _ =
      (try await harness.twitch.helix(
        for: .custom(method: "POST", path: "test", body: ["test": "test"]))).value

    let request = try #require(await harness.session.lastRequest())
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")

    let body = try #require(request.httpBody)
    let decodedBody = try JSONDecoder().decode([String: String].self, from: body)
    #expect(decodedBody == ["test": "test"])
  }

  @Test
  func bodyEncodingFailureIsUnexpectedError() async {
    let endpoint = HelixEndpoint<String?>(
      method: "POST",
      path: "encoding-failure",
      authentication: .either,
      body: { _ in UnencodableBody() },
      responseType: String.self, makeResponse: { $0.data.first })

    do {
      _ = try await harness.twitch.helix(for: endpoint)
      Issue.record("Expected body encoding to fail.")
    } catch HelixError.unexpectedError(let wrapped) {
      #expect(wrapped is BodyEncodingTestError)
    } catch {
      Issue.record("Unexpected error: \(error)")
    }

    #expect(await harness.session.lastRequest() == nil)
  }

  @Test
  func errorResponse() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/invalid"))
    await harness.session.stub(
      url: url,
      status: 400,
      body: MockedData.errorResponseJSON)

    let error = await #expect(throws: HelixError.self) {
      try await harness.twitch.helix(
        for: .custom(method: "GET", path: "invalid"))
    }

    guard case .twitchError(let name, let status, let message) = error else {
      Issue.record("Expected a twitchError, got \(String(describing: error))")
      return
    }

    #expect(name == "Bad Request")
    #expect(status == 400)
    #expect(message == "Invalid request")
  }

  @Test
  func invalidResponse() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/invalid"))
    await harness.session.stub(url: url)

    let error = await #expect(throws: HelixError.self) {
      try await harness.twitch.helix(
        for: .custom(method: "GET", path: "invalid"))
    }

    guard case .parsingResponseFailed = error else {
      Issue.record("Expected parsingResponseFailed, got \(String(describing: error))")
      return
    }
  }

  @Test
  func emptyEndpointRejectsAnUnexpectedBody() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/empty"))
    let body = Data("unexpected body".utf8)
    await harness.session.stub(url: url, method: "DELETE", status: 200, body: body)
    let endpoint: HelixEndpoint<Void> = .init(
      method: "DELETE", path: "empty", authentication: .either)
    let error = await #expect(throws: HelixError.self) {
      try await harness.twitch.helix(for: endpoint)
    }
    guard case .nonEmptyResponse(let responseData) = error else {
      Issue.record("Expected nonEmptyResponse, got \(String(describing: error))")
      return
    }
    #expect(responseData == body)
  }

  @Test
  func invalidErrorResponse() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/invalid"))
    await harness.session.stub(url: url, status: 500)

    let error = await #expect(throws: HelixError.self) {
      try await harness.twitch.helix(
        for: .custom(method: "GET", path: "invalid"))
    }

    guard case .parsingErrorFailed = error else {
      Issue.record("Expected parsingErrorFailed, got \(String(describing: error))")
      return
    }
  }

  @Test(arguments: HelixCancellationSource.allCases)
  func asyncCancellation(source: HelixCancellationSource) async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/cancel"))
    await harness.session.stub(url: url, error: source.error)

    await #expect(throws: CancellationError.self) {
      try await harness.twitch.helix(
        for: .custom(method: "GET", path: "cancel"))
    }
  }

  @Test("Cancelling helixTask completes with a cancellation error")
  func callbackCancellation() async {
    let twitch = TwitchClient(
      credentials: .init(
        accessToken: "abcdefg",
        clientID: "123456",
        userID: "1234",
        userLogin: "user"),
      network: SuspendingNetworkSession())

    let result: Result<HelixResponse<String?>, HelixError> = await withCheckedContinuation {
      continuation in
      let cancellable = twitch.helixTask(
        for: .custom(method: "GET", path: "cancel"),
        completionHandler: { result in
          continuation.resume(returning: result)
        })

      cancellable.cancel()
    }

    guard case .failure(.cancelled) = result else {
      Issue.record("Expected callback cancellation, got \(result)")
      return
    }
  }

  @Test("helixTask completes with unexpected errors")
  func callbackUnexpectedError() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/unexpected"))
    await harness.session.stub(
      url: url,
      body: Data("{\"data\":[\"value\"]}".utf8))

    let endpoint = HelixEndpoint<String?>(
      method: "GET",
      path: "unexpected",
      authentication: .either,
      responseType: String.self,
      makeResponse: { _ in throw HelixCallbackTestError.unexpected })

    let result: Result<HelixResponse<String?>, HelixError> = await withCheckedContinuation {
      continuation in
      harness.twitch.helixTask(
        for: endpoint,
        completionHandler: { result in
          continuation.resume(returning: result)
        })
    }

    guard case .failure(.unexpectedError(let wrapped)) = result else {
      Issue.record("Expected an unexpected callback error, got \(result)")
      return
    }

    let error = try #require(wrapped as? HelixCallbackTestError)
    #expect(error == .unexpected)
  }

  @Test
  func missingOrMalformedDataIsRejected() throws {
    let decoder = TwitchClient.makeDecoder()
    #expect(throws: DecodingError.self) {
      try decoder.decode(
        HelixResponsePayload<UserColor>.self, from: Data(#"{"data":42}"#.utf8))
    }
    #expect(throws: DecodingError.self) {
      try decoder.decode(HelixResponsePayload<UserColor>.self, from: Data(#"{}"#.utf8))
    }
  }
}

private final class CalendarURLProtocol: URLProtocol {
  override static func canInit(with request: URLRequest) -> Bool { true }

  override static func canonicalRequest(for request: URLRequest) -> URLRequest { request }

  override func startLoading() {
    guard let url = request.url,
      url.absoluteString == "https://api.twitch.tv/helix/schedule/icalendar?broadcaster_id=1234",
      request.value(forHTTPHeaderField: "Authorization") == nil,
      request.value(forHTTPHeaderField: "Client-Id") == nil,
      let response = HTTPURLResponse(
        url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
    else {
      client?.urlProtocol(self, didFailWithError: URLError(.badURL))
      return
    }
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    client?.urlProtocol(self, didLoad: Data("BEGIN:VCALENDAR".utf8))
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}
}

enum HelixCancellationSource: CaseIterable, Sendable {
  case cancellationError
  case urlError

  var error: any Error {
    switch self {
    case .cancellationError:
      CancellationError()
    case .urlError:
      URLError(.cancelled)
    }
  }
}

private enum HelixCallbackTestError: Error, Equatable {
  case requestDidNotCancel
  case unexpected
}

private enum BodyEncodingTestError: Error {
  case failed
}

private struct UnencodableBody: Encodable, Sendable {
  func encode(to encoder: Encoder) throws {
    throw BodyEncodingTestError.failed
  }
}

private actor SuspendingNetworkSession: NetworkSession {
  func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    try await Task.sleep(for: .seconds(60))
    throw HelixCallbackTestError.requestDidNotCancel
  }

  func webSocketTask(with url: URL) async -> WebSocketTask {
    fatalError("WebSocket tasks are not used by these tests.")
  }
}
