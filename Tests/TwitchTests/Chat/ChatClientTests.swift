import Twitch
import XCTest

class ChatClientTests: XCTestCase {
  func testAnonymous() { _ = ChatClient(.anonymous) }
  func testAuthenticated() {
    _ = ChatClient(.authenticated(TwitchCredentials(oAuth: "1234567")))
  }
}
