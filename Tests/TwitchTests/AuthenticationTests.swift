import XCTest

@testable import Twitch

class AuthenticationTests: XCTestCase {
  func testOAuthWithClientID() {
    let oAuth = "oauth:abcdefghijklmnop"
    let clientID = "1234567890"
    let auth = TwitchCredentials(oAuth: oAuth, clientID: clientID)

    XCTAssertEqual(auth.oAuth, oAuth)
    XCTAssertEqual(auth.clientID, clientID)
  }

  func testOAuthNoClientID() {
    let oAuth = "oauth:abcdefghijklmnop"
    let auth = TwitchCredentials(oAuth: oAuth)

    XCTAssertNil(auth.clientID)
  }

  func testOAuthWithoutPrefix() {
    let oAuth = "abcdefghijklmnop"
    let auth = TwitchCredentials(oAuth: oAuth)

    XCTAssertEqual(auth.oAuth, "oauth:" + oAuth)
  }

  func testHTTPHeaders() throws {
    let oAuth = "abcdefghijklmnop"
    let clientID = "1234567890"
    let auth = TwitchCredentials(oAuth: oAuth, clientID: clientID)

    let headers = try auth.httpHeaders()

    XCTAssert(
      headers.contains(where: {
        $0.key == "Authorization" && $0.value == "Bearer \(oAuth)"
      }))
    XCTAssert(
      headers.contains(where: { $0.key == "Client-Id" && $0.value == clientID })
    )
  }

  func testHTTPHeadersWithoutClientId() {
    let oAuth = "abcdefghijklmnop"
    let auth = TwitchCredentials(oAuth: oAuth)

    XCTAssertThrowsError(try auth.httpHeaders())
  }
}
