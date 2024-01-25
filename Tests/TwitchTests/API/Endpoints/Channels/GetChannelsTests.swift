import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class GetChannelsTests: XCTestCase {
  private var helix: Helix!

  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    let urlSession = URLSession(configuration: configuration)

    helix = try Helix(
      authentication: .init(oAuth: "1234567989", clientID: "abcdefghijkl"),
      urlSession: urlSession)
  }

  func testGetChannels() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/channels?broadcaster_id=141981764")!

    Mock(
      url: url, dataType: .json, statusCode: 200, data: [.get: MockedData.getChannelsJSON]
    ).register()

    let channels = try await helix.getChannels(userIDs: ["141981764"])

    XCTAssertEqual(channels.count, 1)
    XCTAssert(channels.contains(where: { $0.id == "141981764" }))
  }

  func testGetChannelsWithMultipleIDs() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/channels?broadcaster_id=141981764&broadcaster_id=22484632"
    )!

    Mock(
      url: url, dataType: .json, statusCode: 200,
      data: [.get: MockedData.getMultipleChannelsJSON]
    ).register()

    let channels = try await helix.getChannels(userIDs: ["141981764", "22484632"])

    XCTAssertEqual(channels.count, 2)
  }

  func testGetChannelsWithInvalidRequest() async {
    let url = URL(string: "https://api.twitch.tv/helix/channels")!

    Mock(
      url: url, dataType: .json, statusCode: 400,
      data: [.get: MockedData.getChannelsNoBroadcasterIDJSON]
    ).register()

    await XCTAssertThrowsErrorAsync(
      try await helix.getChannels(userIDs: []),
      "An invalid request should throw an error."
    ) { err in
      guard case HelixError.requestFailed(let error, let status, let message) = err else {
        return XCTFail(
          "An invalid request should throw a requestFailed error, not \(err).")
      }

      XCTAssertEqual(error, "Bad Request")
      XCTAssertEqual(status, 400)
      XCTAssertEqual(message, "Missing required parameter \"broadcaster_id\"")
    }
  }

  func testGetChannelsInvalidResponse() async {
    let url = URL(string: "https://api.twitch.tv/helix/channels")!

    Mock(url: url, dataType: .json, statusCode: 200, data: [.get: Data()]).register()

    await XCTAssertThrowsErrorAsync(
      try await helix.getChannels(userIDs: []),
      "An invalid reponse should throw an error."
    ) { error in
      guard case HelixError.invalidResponse = error else {
        return XCTFail("An invalid response should throw an invalidResponse HelixError")
      }
    }
  }
}
