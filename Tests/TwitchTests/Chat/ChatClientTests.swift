import Twitch
import XCTest

class ChatClientTests: XCTestCase {
  func testAnonymous() { _ = ChatClient(.anonymous) }
  func testAuthenticated() {
    _ = ChatClient(
      .authenticated(loginName: "justinfan12345", TwitchCredentials(oAuth: "1234567")))
  }

  func testCapabilities() async throws {}
}
