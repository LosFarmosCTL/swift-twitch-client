import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

class HelixTests: XCTestCase {
  private var mockingURLSession: URLSession!
  private var twitch: TwitchClient!

  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    self.mockingURLSession = URLSession(configuration: configuration)

    self.twitch = TwitchClient(
      authentication: .init(
        oAuth: "abcdefg", clientID: "123456", userID: "1234", userLogin: "user"),
      urlSession: mockingURLSession)
  }

  func testHelixAuthentication() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/chat/badges/global")!
    var mock = Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: "{\"data\":[]}".data(using: .utf8)!])

    mock.onRequestHandler = OnRequestHandler(requestCallback: { request in
      guard let clientIDHeader = request.value(forHTTPHeaderField: "Client-Id") else {
        return XCTFail("Helix request must contain a Client-Id header.")
      }

      guard let authenticationHeader = request.value(forHTTPHeaderField: "Authorization")
      else { return XCTFail("Helix request must contain an Authorization header.") }

      XCTAssertEqual(
        clientIDHeader, "123456",
        "Helix request must contain the correct Client-Id header.")
      XCTAssertEqual(
        authenticationHeader, "Bearer abcdefg",
        "Helix request must contain the correct Authorization header.")
    })

    mock.register()

    _ = try await self.twitch.request(endpoint: .getGlobalBadges())
  }

  func testWithJsonBody() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/test")!
    var mock = Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.post: "{\"data\":[\"forsen\"]}".data(using: .utf8)!])

    mock.onRequestHandler = OnRequestHandler(
      httpBodyType: [String: String].self,
      callback: { request, body in
        XCTAssertEqual(
          request.value(forHTTPHeaderField: "Content-Type"), "application/json",
          "Helix request must contain the correct Content-Type header.")

        guard let body else { return XCTFail("Helix request must contain a body.") }

        XCTAssertEqual(
          body, ["test": "test"], "Helix request must contain the correct body.")
      })

    mock.register()

    _ = try await self.twitch.request(
      endpoint: .custom(method: "POST", path: "test", body: ["test": "test"]))
  }

  func testErrorResponse() async {
    let url = URL(string: "https://api.twitch.tv/helix/invalid")!

    Mock(
      url: url, contentType: .json, statusCode: 400,
      data: [.get: MockedData.errorResponseJSON]
    ).register()

    await XCTAssertThrowsErrorAsync(
      try await twitch.request(endpoint: .custom(method: "GET", path: "invalid")),
      "An invalid request should throw an error."
    ) { err in
      guard case HelixError.twitchError(let name, let status, let message) = err else {
        return XCTFail(
          "An invalid request should throw a requestFailed error, not \(err).")
      }

      XCTAssertEqual(name, "Bad Request")
      XCTAssertEqual(status, 400)
      XCTAssertEqual(message, "Invalid request")
    }
  }

  func testInvalidResponse() async {
    let url = URL(string: "https://api.twitch.tv/helix/invalid")!

    Mock(url: url, contentType: .json, statusCode: 200, data: [.get: Data()])
      .register()

    await XCTAssertThrowsErrorAsync(
      try await self.twitch.request(endpoint: .custom(method: "GET", path: "invalid")),
      "An invalid response should throw a HelixError",
      { (error) in
        guard case HelixError.parsingResponseFailed(_) = error else {
          return XCTFail(
            "An invalid response should throw a parsingResponseFailed HelixError")
        }
      })
  }

  func testInvalidErrorResponse() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/invalid")!
    Mock(
      url: url, contentType: .json, statusCode: 500, data: [.get: "".data(using: .utf8)!]
    ).register()

    await XCTAssertThrowsErrorAsync(
      try await self.twitch.request(endpoint: .custom(method: "GET", path: "invalid")),
      "An invalid response should throw a HelixError",
      { (error) in
        guard case HelixError.parsingErrorFailed(_, _) = error else {
          return XCTFail(
            "An invalid error response should throw an invalidErrorResponse HelixError")
        }
      })
  }
}
