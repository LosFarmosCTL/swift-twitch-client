import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

class HelixTests: XCTestCase {
  var mockingURLSession: URLSession!

  func testHelixInitialization() {
    XCTAssertNoThrow(
      try Helix(authentication: .init(oAuth: "abcdefg", clientID: "123456789")))
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

  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    mockingURLSession = URLSession(configuration: configuration)
  }

  func testHelixAuthentication() async throws {
    let oAuth = "abcdefg"
    let clientID = "123456"

    let helix = try Helix(
      authentication: .init(oAuth: oAuth, clientID: clientID),
      urlSession: mockingURLSession)

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
        clientIDHeader, clientID,
        "Helix request must contain the correct Client-Id header.")
      XCTAssertEqual(
        authenticationHeader, "Bearer " + oAuth,
        "Helix request must contain the correct Authorization header.")
    })

    mock.register()

    let _: [String] = try await helix.request(.get("test"))
  }

  func testInvalidErrorResponse() async throws {
    let oAuth = "abcdefg"
    let clientID = "123456"

    let helix = try Helix(
      authentication: .init(oAuth: oAuth, clientID: clientID),
      urlSession: mockingURLSession)

    let url = URL(string: "https://api.twitch.tv/helix/invalid")!
    Mock(url: url, dataType: .json, statusCode: 500, data: [.get: "".data(using: .utf8)!])
      .register()

    await XCTAssertThrowsErrorAsync(
      { let _: [String] = try await helix.request(.get("invalid")) },
      "An invalid response should throw a HelixError",
      { (error) in
        guard case HelixError.invalidErrorResponse = error else {
          return XCTFail(
            "An invalid error response should throw an invalidErrorResponse HelixError")
        }
      })
  }
}
