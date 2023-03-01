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
    XCTAssertThrowsError(
      try Helix(authentication: .init(oAuth: "abcdefghijkl123456789"))
    ) { error in
      guard case HelixError.missingClientID = error else {
        return XCTFail(
          "Initializing Helix without a ClientID should throw a missingClientID error."
        )
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
      url: url, dataType: .json, statusCode: 200, data: [.get: Data()])

    mock.onRequestHandler = OnRequestHandler(requestCallback: { request in
      guard let clientIDHeader = request.value(forHTTPHeaderField: "Client-Id")
      else { return XCTFail("Helix request must contain a Client-Id header.") }

      guard
        let authenticationHeader = request.value(
          forHTTPHeaderField: "Authorization")
      else {
        return XCTFail("Helix request must contain an Authorization header.")
      }

      XCTAssertEqual(
        clientIDHeader, clientID,
        "Helix request must contain the correct Client-Id header.")
      XCTAssertEqual(
        authenticationHeader, "Bearer " + oAuth,
        "Helix request must contain the correct Authorization header.")
    })

    mock.register()

    _ = try await helix.request(.get("test"))
  }
}
