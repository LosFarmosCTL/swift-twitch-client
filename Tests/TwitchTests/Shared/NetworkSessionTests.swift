import Foundation
import Testing

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

struct NetworkSessionTests {
  @Test("Rejects non-HTTP URL responses")
  func rejectsNonHTTPURLResponse() async throws {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [NonHTTPURLProtocol.self]

    let session = URLSession(configuration: configuration)
    defer { session.invalidateAndCancel() }

    let network = URLSessionNetworkSession(session: session)
    let url = try #require(URL(string: "https://example.com"))

    do {
      _ = try await network.data(for: URLRequest(url: url))
      Issue.record("Expected a non-HTTP response to be rejected.")
    } catch let error as URLError {
      #expect(error.code == .badServerResponse)
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test(
    "Cancelling a data request cancels its URLSession task",
    .timeLimit(.minutes(1)))
  func cancellationStopsURLSessionTask() async throws {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [CancellationURLProtocol.self]

    let session = URLSession(configuration: configuration)
    defer { session.invalidateAndCancel() }

    let network = URLSessionNetworkSession(session: session)
    let url = try #require(URL(string: "https://example.com/cancel"))
    var started = CancellationURLProtocolSignals.started.stream.makeAsyncIterator()
    var stopped = CancellationURLProtocolSignals.stopped.stream.makeAsyncIterator()

    let task = Task {
      try await network.data(for: URLRequest(url: url))
    }

    _ = await started.next()
    task.cancel()
    _ = await stopped.next()

    switch await task.result {
    case .success:
      Issue.record("Expected the cancelled request to throw.")
    case .failure(let error as URLError):
      #expect(error.code == .cancelled)
    case .failure(is CancellationError):
      break
    case .failure(let error):
      Issue.record("Unexpected error: \(error)")
    }
  }
}

private final class NonHTTPURLProtocol: URLProtocol {
  override static func canInit(with request: URLRequest) -> Bool {
    true
  }

  override static func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    guard let url = request.url else {
      client?.urlProtocol(self, didFailWithError: URLError(.badURL))
      return
    }

    let response = URLResponse(
      url: url,
      mimeType: nil,
      expectedContentLength: 0,
      textEncodingName: nil)

    client?.urlProtocol(
      self,
      didReceive: response,
      cacheStoragePolicy: .notAllowed)
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}
}

private enum CancellationURLProtocolSignals {
  static let started = AsyncStream<Void>.makeStream()
  static let stopped = AsyncStream<Void>.makeStream()
}

private final class CancellationURLProtocol: URLProtocol {
  override static func canInit(with request: URLRequest) -> Bool {
    true
  }

  override static func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    CancellationURLProtocolSignals.started.continuation.yield()
  }

  override func stopLoading() {
    CancellationURLProtocolSignals.stopped.continuation.yield()
  }
}
