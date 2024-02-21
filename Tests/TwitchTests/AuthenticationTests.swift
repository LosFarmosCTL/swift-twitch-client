import XCTest

@testable import Twitch

class AuthenticationTests: XCTestCase {
  let oAuth = "abcdefghijklmnop"
  let clientID = "1234567890"
  let userID = "1234"

  func testOAuthWithPrefix() {
    let auth = TwitchCredentials(
      oAuth: "oauth:" + oAuth, clientID: clientID, userId: userID)

    XCTAssertEqual(auth.oAuth, "oauth:" + oAuth)
  }

  func testOAuthWithoutPrefix() {
    let auth = TwitchCredentials(oAuth: oAuth, clientID: clientID, userId: userID)

    XCTAssertEqual(auth.oAuth, "oauth:" + oAuth)
  }

  func testHTTPHeaders() throws {
    let auth = TwitchCredentials(oAuth: oAuth, clientID: clientID, userId: userID)

    let headers = auth.httpHeaders()

    XCTAssert(
      headers.contains(where: {
        $0.key == "Authorization" && $0.value == "Bearer \(oAuth)"
      }))
    XCTAssert(headers.contains(where: { $0.key == "Client-Id" && $0.value == clientID }))
  }
}
