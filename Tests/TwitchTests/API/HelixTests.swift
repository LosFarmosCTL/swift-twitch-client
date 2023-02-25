import Foundation
import XCTest

@testable import Twitch

class HelixTests: XCTestCase {
  func testHelixInitialization() {
    XCTAssertNoThrow(try Helix(authentication: .init(oAuth: "abcdefg", clientID: "123456789")))
  }

  func testHelixInitializationWithoutClientId() {
    XCTAssertThrowsError(try Helix(authentication: .init(oAuth: "abcdefg"))) { error in
      guard case HelixError.missingClientID = error else {
        return XCTFail(
          "Initializing Helix without a ClientID should throw a missingClientID error.")
      }
    }
  }
}
