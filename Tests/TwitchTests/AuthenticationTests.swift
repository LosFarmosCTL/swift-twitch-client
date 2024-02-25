import XCTest

@testable import Twitch

class AuthenticationTests: XCTestCase {
  let oAuth = "abcdefghijklmnop"
  let clientID = "1234567890"
  let userID = "1234"
  let userLogin = "user"

  func testInitialization() {
    let auth = TwitchCredentials(
      oAuth: oAuth, clientID: clientID, userID: userID, userLogin: userLogin)

    XCTAssertEqual(auth.oAuth, oAuth)
    XCTAssertEqual(auth.clientID, clientID)
    XCTAssertEqual(auth.userID, userID)
    XCTAssertEqual(auth.userLogin, userLogin)
  }

  func testWithOAuthPrefix() {
    let auth = TwitchCredentials(
      oAuth: "oauth:" + oAuth, clientID: clientID, userID: userID, userLogin: userLogin)

    XCTAssertEqual(auth.oAuth, oAuth)
  }

  func testHTTPHeaders() throws {
    let auth = TwitchCredentials(
      oAuth: oAuth, clientID: clientID, userID: userID, userLogin: userLogin)

    let headers = auth.httpHeaders()

    XCTAssert(
      headers.contains(where: {
        $0.key == "Authorization" && $0.value == "Bearer \(oAuth)"
      }))
    XCTAssert(headers.contains(where: { $0.key == "Client-Id" && $0.value == clientID }))
  }
}
