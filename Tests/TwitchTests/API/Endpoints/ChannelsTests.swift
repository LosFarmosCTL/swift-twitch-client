import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class ChannelsTests: XCTestCase {
  private var helix: Helix!

  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    let urlSession = URLSession(configuration: configuration)

    helix = try Helix(
      authentication: .init(
        oAuth: "1234567989", clientID: "abcdefghijkl", userId: "1234"),
      urlSession: urlSession)
  }

  func testGetChannels() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/channels?broadcaster_id=141981764")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getChannelsJSON]
    ).register()

    let channels = try await helix.getChannels(userIDs: ["141981764"])

    XCTAssertEqual(channels.count, 1)
    XCTAssert(channels.contains(where: { $0.id == "141981764" }))
  }

  func testGetChannelEditors() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/channels/editors?broadcaster_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getChannelEditorsJSON]
    ).register()

    let editors = try await helix.getChannelEditors()

    XCTAssertEqual(editors.count, 2)

    XCTAssertEqual(editors.first?.userId, "182891647")
    XCTAssertEqual(editors.last?.userId, "135093069")

    XCTAssertEqual(editors.first?.createdAt.formatted(.iso8601), "2019-02-15T21:19:50Z")
  }

  func testGetFollowedChannels() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/channels/followed?user_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getFollowedChannelsJSON]
    ).register()

    let (total, follows, cursor) = try await helix.getFollowedChannels()

    XCTAssertEqual(total, 8)

    XCTAssertEqual(follows.first?.broadcasterId, "11111")
    XCTAssertEqual(follows.first?.followedAt.formatted(.iso8601), "2022-05-24T22:22:08Z")

    XCTAssertEqual(cursor, "eyJiIjpudWxsLCJhIjp7Ik9mZnNldCI6NX19")
  }

  func testCheckFollow() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/channels/followed?user_id=123456&broadcaster_id=654321"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.checkFollowJSON]
    ).register()

    let follow = try await helix.checkFollow(from: "123456", to: "654321")

    XCTAssertEqual(follow?.broadcasterId, "654321")
    XCTAssertEqual(follow?.followedAt.formatted(.iso8601), "2022-05-24T22:22:08Z")
  }

  func testGetChannelFollowers() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/channels/followers?broadcaster_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getChannelFollowersJSON]
    ).register()

    let (total, follows, cursor) = try await helix.getChannelFollowers(
      broadcasterId: "1234")

    XCTAssertEqual(total, 8)

    XCTAssertEqual(follows.first?.userId, "11111")
    XCTAssertEqual(follows.first?.followedAt.formatted(.iso8601), "2022-05-24T22:22:08Z")

    XCTAssertEqual(cursor, "eyJiIjpudWxsLCJhIjp7Ik9mZnNldCI6NX19")
  }

  func testCheckChannelFollower() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/channels/followers?user_id=654321&broadcaster_id=123456"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.checkChannelFollowerJSON]
    ).register()

    let follow = try await helix.checkChannelFollower(userId: "654321", follows: "123456")

    XCTAssertEqual(follow?.userId, "654321")
    XCTAssertEqual(follow?.followedAt.formatted(.iso8601), "2022-05-24T22:22:08Z")
  }

  func testUpdateChannel() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/channels?broadcaster_id=1234")!
    var request = URLRequest(url: url)
    request.httpMethod = "PATCH"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await helix.updateChannel(gameId: "1234")

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }
}
