import Foundation
import Testing

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

struct ValidateTokenTests {
  @Test
  func requestAndResponse() async throws {
    let session = MockNetworkSession()
    let url = try #require(URL(string: "https://id.twitch.tv/oauth2/validate"))
    await session.stub(
      url: url,
      body: validationResponse(expiresIn: 3600))

    let token = try await TwitchClient.validateToken(
      token: "oauth-token",
      network: session)

    #expect(token.clientID == "client-id")
    #expect(token.login == "some_login")
    #expect(token.userID == "1234")
    #expect(token.scopes == ["chat:read", "user:read:email"])
    #expect(token.expiresIn == 3600)

    let request = try #require(await session.lastRequest())
    #expect(request.url == url)
    #expect(request.httpMethod == "GET")
    #expect(
      request.value(forHTTPHeaderField: "Authorization") == "OAuth oauth-token")
  }

  @Test
  func zeroExpiryBecomesNil() async throws {
    let session = MockNetworkSession()
    let url = try #require(URL(string: "https://id.twitch.tv/oauth2/validate"))
    await session.stub(
      url: url,
      body: validationResponse(expiresIn: 0))

    let token = try await TwitchClient.validateToken(
      token: "oauth-token",
      network: session)

    #expect(token.expiresIn == nil)
  }

  @Test
  func invalidStatus() async throws {
    let session = MockNetworkSession()
    let url = try #require(URL(string: "https://id.twitch.tv/oauth2/validate"))
    await session.stub(url: url, status: 401)

    let error = await #expect(throws: ValidationError.self) {
      try await TwitchClient.validateToken(
        token: "invalid-token",
        network: session)
    }

    guard case .invalidToken = error else {
      Issue.record("Expected invalidToken, got \(String(describing: error))")
      return
    }
  }

  @Test
  func malformedResponse() async throws {
    let session = MockNetworkSession()
    let url = try #require(URL(string: "https://id.twitch.tv/oauth2/validate"))
    await session.stub(url: url, body: Data("{}".utf8))

    await #expect(throws: DecodingError.self) {
      try await TwitchClient.validateToken(
        token: "oauth-token",
        network: session)
    }
  }

  @Test(arguments: ValidateTokenCancellationSource.allCases)
  func cancellation(source: ValidateTokenCancellationSource) async throws {
    let session = MockNetworkSession()
    let url = try #require(URL(string: "https://id.twitch.tv/oauth2/validate"))
    await session.stub(url: url, error: source.error)

    await #expect(throws: CancellationError.self) {
      try await TwitchClient.validateToken(
        token: "oauth-token",
        network: session)
    }
  }

  @Test
  func networkErrorPassesThrough() async throws {
    let session = MockNetworkSession()
    let url = try #require(URL(string: "https://id.twitch.tv/oauth2/validate"))
    await session.stub(url: url, error: URLError(.notConnectedToInternet))

    do {
      _ = try await TwitchClient.validateToken(
        token: "oauth-token",
        network: session)
      Issue.record("Expected a network error.")
    } catch let error as URLError {
      #expect(error.code == .notConnectedToInternet)
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }
}

enum ValidateTokenCancellationSource: CaseIterable, Sendable {
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

private func validationResponse(expiresIn: Int) -> Data {
  Data(
    """
    {
      "client_id": "client-id",
      "login": "some_login",
      "user_id": "1234",
      "scopes": ["chat:read", "user:read:email"],
      "expires_in": \(expiresIn)
    }
    """.utf8)
}
