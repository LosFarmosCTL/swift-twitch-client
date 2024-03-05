import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class SearchTests: XCTestCase {
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

  func testSearchCategories() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/search/categories?query=fort")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.searchCategoriesJSON]
    ).register()

    let (categories, cursor) = try await twitch.request(
      endpoint: .searchCategories(for: "fort"))

    XCTAssertEqual(cursor, "eyJiIjpudWxsLCJhIjp7IkN")

    XCTAssertEqual(categories.count, 1)
    XCTAssert(categories.contains(where: { $0.id == "33214" }))
  }

  func testSearchChannels() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/search/channels?query=loser")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.searchChannelsJSON]
    ).register()

    let (channels, cursor) = try await twitch.request(
      endpoint: .searchChannels(for: "loser"))

    XCTAssertNil(cursor)

    XCTAssertEqual(channels.count, 2)
    XCTAssert(channels.contains(where: { $0.id == "41245072" }))
  }
}
