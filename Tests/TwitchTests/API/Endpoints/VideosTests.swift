import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class VideosTests: XCTestCase {
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

  func testGetVideos() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/videos?id=987654321")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getVideosJSON]
    ).register()

    let (videos, cursor) = try await twitch.helix(
      endpoint: .getVideos(ids: ["987654321"]))

    XCTAssertNil(cursor)

    XCTAssertEqual(videos.count, 1)

    let video = try XCTUnwrap(videos.first)
    XCTAssertEqual(video.id, "987654321")
    XCTAssertEqual(video.streamID, "111222333")
    XCTAssertEqual(video.userID, "56789")
    XCTAssertEqual(video.userLogin, "zzzztopper")
    XCTAssertEqual(video.userName, "zzzzTopper")
    XCTAssertEqual(video.title, "The incredible artistry that is me.")
    XCTAssertEqual(video.description, "")
    XCTAssertEqual(video.createdAt.formatted(.iso8601), "2022-07-08T16:58:46Z")
    XCTAssertEqual(video.publishedAt.formatted(.iso8601), "2022-07-08T16:58:46Z")
    XCTAssertEqual(video.url, "https://www.twitch.tv/videos/987654321")
    XCTAssertEqual(
      video.thumbnailURL,
      "https://static-cdn.jtvnw.net/cf_vods/dgeft87wbj63p/ce4ddf3095472cde00cd_zzzztopper_45725106652_1657299521//thumb/thumb0-%{width}x%{height}.jpg"
    )
    XCTAssertEqual(video.viewable, "public")
    XCTAssertEqual(video.viewCount, 395_246)
    XCTAssertEqual(video.language, "en")
    XCTAssertEqual(video.type, .archive)
    XCTAssertEqual(video.duration, "6h26m14s")
    XCTAssertNil(video.mutedSegments)
  }

  func testDeleteVideos() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/videos?id=1535513785")!
    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.delete: MockedData.deleteVideosJSON]
    ).register()

    let deletedIDs = try await twitch.helix(endpoint: .deleteVideos(ids: ["1535513785"]))

    XCTAssertEqual(deletedIDs, ["1535513785"])
  }
}
