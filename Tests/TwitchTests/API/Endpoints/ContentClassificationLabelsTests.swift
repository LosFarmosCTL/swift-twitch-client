import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class ContentClassificationLabelsTests: XCTestCase {
  private var twitch: TwitchClient!

  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    let urlSession = URLSession(configuration: configuration)

    twitch = TwitchClient(
      authentication: .init(
        oAuth: "1234567989", clientID: "abcdefghijkl", userID: "1234", userLogin: "user"),
      urlSession: urlSession)
  }

  func testGetContentClassificationLabels() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/content_classification_labels?locale=en-US")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getContentClassificationLabelsJSON]
    ).register()

    let labels = try await twitch.helix(endpoint: .getContentClassificationLabels())

    XCTAssertEqual(labels.count, 6)
    XCTAssert(labels.contains(where: { $0.id == "ViolentGraphic" }))
  }
}
