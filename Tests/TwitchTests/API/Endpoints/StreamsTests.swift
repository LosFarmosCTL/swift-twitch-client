import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class StreamsTests: XCTestCase {
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

  func testGetStreams() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/streams?first=1")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getStreamsJSON]
    ).register()

    let (streams, cursor) = try await twitch.request(endpoint: .getStreams(limit: 1))

    XCTAssertNil(cursor)

    XCTAssertEqual(streams.count, 1)
    XCTAssert(streams.contains(where: { $0.id == "40952121085" }))
  }

  func testGetFollowedStreams() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/streams/followed?user_id=1234&first=1")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getFollowedStreamsJSON]
    ).register()

    let (streams, cursor) = try await twitch.request(
      endpoint: .getFollowedStreams(limit: 1))

    XCTAssertEqual(cursor, "eyJiIjp7IkN1cnNvciI6ImV5SnpJam8zT0RNMk5TNDBORFF4")

    XCTAssertEqual(streams.count, 1)
    XCTAssert(streams.contains(where: { $0.id == "42170724654" }))
  }
}
