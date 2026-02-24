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

    twitch = TwitchClient(
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

    let (streams, cursor) = try await twitch.helix(endpoint: .getStreams(limit: 1))

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

    let (streams, cursor) = try await twitch.helix(
      endpoint: .getFollowedStreams(limit: 1))

    XCTAssertEqual(cursor, "eyJiIjp7IkN1cnNvciI6ImV5SnpJam8zT0RNMk5TNDBORFF4")

    XCTAssertEqual(streams.count, 1)
    XCTAssert(streams.contains(where: { $0.id == "42170724654" }))
  }

  func testGetStreamKey() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/streams/key?broadcaster_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getStreamKeyJSON]
    ).register()

    let key = try await twitch.helix(endpoint: .getStreamKey())

    XCTAssertEqual(key, "live_44322889_a34ub37c8ajv98a0")
  }

  func testCreateStreamMarker() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/streams/markers")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.post: MockedData.createStreamMarkerJSON]
    ).register()

    let marker = try await twitch.helix(
      endpoint: .createStreamMarker(description: "hello, this is a marker!"))

    XCTAssertEqual(marker.id, "123")
    XCTAssertEqual(marker.positionSeconds, 244)
    XCTAssertEqual(marker.description, "hello, this is a marker!")
    XCTAssertEqual(marker.createdAt.formatted(.iso8601), "2018-08-20T20:10:03Z")
  }

  func testGetStreamMarkers() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/streams/markers?user_id=1234&first=1")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getStreamMarkersJSON]
    ).register()

    let (markers, cursor) = try await twitch.helix(
      endpoint: .getStreamMarkers(userID: "1234", limit: 1))

    XCTAssertEqual(
      cursor, "eyJiIjpudWxsLCJhIjoiMjk1MjA0Mzk3OjI1Mzpib29rbWFyazoxMDZiOGQ1Y")

    XCTAssertEqual(markers.count, 1)
    XCTAssertEqual(markers.first?.userID, "1234")
    XCTAssertEqual(markers.first?.userLogin, "user")

    let video = try XCTUnwrap(markers.first?.videos.first)
    XCTAssertEqual(video.videoID, "456")

    let marker = try XCTUnwrap(video.markers.first)
    XCTAssertEqual(marker.id, "106b8d6243a4f883d25ad75e6cdffdc4")
    XCTAssertEqual(marker.positionSeconds, 244)
    XCTAssertEqual(marker.description, "hello, this is a marker!")
    XCTAssertEqual(
      marker.url,
      "https://twitch.tv/user/manager/highlighter/456?t=0h4m06s")
  }
}
