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
