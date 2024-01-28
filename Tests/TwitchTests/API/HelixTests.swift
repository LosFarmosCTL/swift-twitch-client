import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

class HelixTests: XCTestCase {
  private var mockingURLSession: URLSession!
  private var helix: Helix!

  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    self.mockingURLSession = URLSession(configuration: configuration)

    self.helix = try Helix(
      authentication: .init(oAuth: "abcdefg", clientID: "123456"),
      urlSession: mockingURLSession)
  }

  func testHelixInitialization() {
    XCTAssertNoThrow(
      try Helix(authentication: .init(oAuth: "abcdefg", clientID: "123456")))
  }

  func testHelixInitializationWithoutClientId() {
    XCTAssertThrowsError(try Helix(authentication: .init(oAuth: "abcdefghijkl123456789")))
    { error in
      guard case HelixError.missingClientID = error else {
        return XCTFail(
          "Initializing Helix without a ClientID should throw a missingClientID error.")
      }
    }
  }

  func testHelixAuthentication() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/test")!
    var mock = Mock(
      url: url, dataType: .json, statusCode: 200,
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

    let _: ([String], String?) = try await self.helix.request(.get("test"))
  }

  func testPagination() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/paginated")!

    Mock(
      url: url, dataType: .json, statusCode: 200,
      data: [.get: MockedData.paginatedResponseJSON]
    ).register()

    let (result, cursor): ([String], String?) = try await helix.request(.get("paginated"))

    XCTAssertEqual(result, [])
    XCTAssertEqual(cursor, "eyJiIjpudWxsLJxhIjoiIn0gf5")
  }

  func testWithJsonBody() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/test")!
    var mock = Mock(
      url: url, dataType: .json, statusCode: 200,
      data: [.post: "{\"data\":[]}".data(using: .utf8)!])

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

    let _: ([String], String?) = try await self.helix.request(
      .post("test"), jsonBody: ["test": "test"])
  }

  func testErrorResponse() async {
    let url = URL(string: "https://api.twitch.tv/helix/invalid")!

    Mock(
      url: url, dataType: .json, statusCode: 400,
      data: [.get: MockedData.errorResponseJSON]
    ).register()

    await XCTAssertThrowsErrorAsync(
      try await helix.request(.get("invalid")) as ([String], String?),
      "An invalid request should throw an error."
    ) { err in
      guard case HelixError.requestFailed(let error, let status, let message) = err else {
        return XCTFail(
          "An invalid request should throw a requestFailed error, not \(err).")
      }

      XCTAssertEqual(error, "Bad Request")
      XCTAssertEqual(status, 400)
      XCTAssertEqual(message, "Invalid request")
    }
  }

  func testInvalidResponse() async {
    let url = URL(string: "https://api.twitch.tv/helix/invalid")!

    Mock(url: url, dataType: .json, statusCode: 200, data: [.get: Data()]).register()

    await XCTAssertThrowsErrorAsync(
      try await self.helix.request(.get("invalid")) as ([String], String?),
      "An invalid response should throw a HelixError",
      { (error) in
        guard case HelixError.invalidResponse = error else {
          return XCTFail("An invalid response should throw an invalidResponse HelixError")
        }
      })
  }

  func testInvalidErrorResponse() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/invalid")!
    Mock(url: url, dataType: .json, statusCode: 500, data: [.get: "".data(using: .utf8)!])
      .register()

    await XCTAssertThrowsErrorAsync(
      { let _: ([String], String?) = try await self.helix.request(.get("invalid")) },
      "An invalid response should throw a HelixError",
      { (error) in
        guard case HelixError.invalidErrorResponse = error else {
          return XCTFail(
            "An invalid error response should throw an invalidErrorResponse HelixError")
        }
      })
  }
}
