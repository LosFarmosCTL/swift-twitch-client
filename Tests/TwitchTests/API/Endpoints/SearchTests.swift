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

    twitch = try TwitchClient(
      authentication: .init(
        oAuth: "1234567989", clientID: "abcdefghijkl", userId: "1234", userLogin: "user"),
      urlSession: urlSession)
  }

  func testSearchCategories() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/search/categories?query=fort")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.searchCategoriesJSON]
    ).register()

    let result = try await twitch.request(endpoint: .searchCategories(for: "fort"))

    XCTAssertEqual(result.pagination?.cursor, "eyJiIjpudWxsLCJhIjp7IkN")

    XCTAssertEqual(result.data.count, 1)
    XCTAssert(result.data.contains(where: { $0.id == "33214" }))
  }

  func testSearchChannels() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/search/channels?query=loser")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.searchChannelsJSON]
    ).register()

    let result = try await twitch.request(endpoint: .searchChannels(for: "loser"))

    XCTAssertNil(result.pagination?.cursor)

    XCTAssertEqual(result.data.count, 2)
    XCTAssert(result.data.contains(where: { $0.id == "41245072" }))
  }
}
