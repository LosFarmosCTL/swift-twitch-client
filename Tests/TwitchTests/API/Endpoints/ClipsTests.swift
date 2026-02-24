import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class ClipsTests: XCTestCase {
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

  func testCreateClip() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/clips?broadcaster_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 202,
      data: [.post: MockedData.createClipJSON]
    ).register()

    let clip = try await twitch.helix(endpoint: .createClip())

    XCTAssertEqual(clip.id, "FiveWordsForClipSlug")
    XCTAssertEqual(
      clip.editURL,
      "https://www.twitch.tv/twitchdev/clip/FiveWordsForClipSlug"
    )
  }

  func testGetClips() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/clips?id=AwkwardHelplessSalamanderSwiftRage")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getClipsJSON]
    ).register()

    let (clips, cursor) = try await twitch.helix(
      endpoint: .getClips(ids: ["AwkwardHelplessSalamanderSwiftRage"]))

    XCTAssertNil(cursor)
    XCTAssertEqual(clips.count, 1)

    let clip = clips.first
    XCTAssertEqual(clip?.id, "AwkwardHelplessSalamanderSwiftRage")
    XCTAssertEqual(clip?.broadcasterID, "67955580")
    XCTAssertEqual(clip?.creatorID, "53834192")
    XCTAssertEqual(clip?.viewCount, 10)
    XCTAssertEqual(clip?.createdAt.formatted(.iso8601), "2017-11-30T22:34:18Z")
    XCTAssertEqual(
      clip?.thumbnailURL,
      "https://clips-media-assets.twitch.tv/157589949-preview-480x272.jpg")
    XCTAssertEqual(clip?.duration, 60)
    XCTAssertEqual(clip?.vodOffset, 480)
    XCTAssertEqual(clip?.isFeatured, false)
  }
}
