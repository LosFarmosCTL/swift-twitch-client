import Foundation
import Testing

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

struct HelixTests {
  private let harness = HelixTestHarness(
    authentication: .init(
      oAuth: "abcdefg",
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

    _ = try await harness.twitch.helix(endpoint: .getGlobalBadges())

    let request = try #require(await harness.session.lastRequest())
    #expect(request.value(forHTTPHeaderField: "Client-Id") == "123456")
    #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer abcdefg")
  }

  @Test
  func withJSONBody() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/test"))
    await harness.session.stub(
      url: url,
      method: "POST",
      body: Data("{\"data\":[\"forsen\"]}".utf8))

    _ = try await harness.twitch.helix(
      endpoint: .custom(method: "POST", path: "test", body: ["test": "test"]))

    let request = try #require(await harness.session.lastRequest())
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")

    let body = try #require(request.httpBody)
    let decodedBody = try JSONDecoder().decode([String: String].self, from: body)
    #expect(decodedBody == ["test": "test"])
  }

  @Test
  func bodyEncodingFailureIsUnexpectedError() async {
    let endpoint = HelixEndpoint<
      String?, String, HelixEndpointResponseTypes.Normal
    >(
      method: "POST",
      path: "encoding-failure",
      body: { _ in UnencodableBody() },
      makeResponse: { $0.data.first })

    do {
      _ = try await harness.twitch.helix(endpoint: endpoint)
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
        endpoint: .custom(method: "GET", path: "invalid"))
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
        endpoint: .custom(method: "GET", path: "invalid"))
    }

    guard case .parsingResponseFailed = error else {
      Issue.record("Expected parsingResponseFailed, got \(String(describing: error))")
      return
    }
  }

  @Test
  func invalidErrorResponse() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/invalid"))
    await harness.session.stub(url: url, status: 500)

    let error = await #expect(throws: HelixError.self) {
      try await harness.twitch.helix(
        endpoint: .custom(method: "GET", path: "invalid"))
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
        endpoint: .custom(method: "GET", path: "cancel"))
    }
  }

  @Test("Cancelling helixTask completes with a cancellation error")
  func callbackCancellation() async {
    let twitch = TwitchClient(
      authentication: .init(
        oAuth: "abcdefg",
        clientID: "123456",
        userID: "1234",
        userLogin: "user"),
      network: SuspendingNetworkSession())

    let result: Result<String?, HelixError> = await withCheckedContinuation {
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

    let endpoint = HelixEndpoint<
      String?, String, HelixEndpointResponseTypes.Normal
    >(
      method: "GET",
      path: "unexpected",
      makeResponse: { _ in throw HelixCallbackTestError.unexpected })

    let result: Result<String?, HelixError> = await withCheckedContinuation {
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
