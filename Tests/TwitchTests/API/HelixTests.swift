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
}
