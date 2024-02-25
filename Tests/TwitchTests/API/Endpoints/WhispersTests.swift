import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class WhispersTests: XCTestCase {
  private var twitch: TwitchClient!

  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    let urlSession = URLSession(configuration: configuration)

    twitch = try TwitchClient(
      authentication: .init(
        oAuth: "1234567989", clientID: "abcdefghijkl", userID: "1234", userLogin: "user"),
      urlSession: urlSession)
  }

  func testSendWhisper() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/whispers?from_user_id=1234&to_user_id=4321")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.request(
      endpoint: .sendWhisper(from: "1234", to: "4321", message: "Hello, world!"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }
}
