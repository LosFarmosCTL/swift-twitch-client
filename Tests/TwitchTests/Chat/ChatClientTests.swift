import Twitch
import XCTest

class ChatClientTests: XCTestCase {
  func testAnonymous() { _ = ChatClient(.anonymous) }
  func testAuthenticated() {
    _ = ChatClient(
      .authenticated(
        loginName: "justinfan12345",
        TwitchCredentials(oAuth: "1234567", clientID: "1234", userId: "1234")))
  }

  func testCapabilities() async throws {}
}
