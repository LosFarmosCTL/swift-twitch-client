import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class GamesTests: XCTestCase {
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

  func testGetGames() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/games?id=33214")!

    Mock(
      url: url, contentType: .json, statusCode: 200, data: [.get: MockedData.getGamesJSON]
    ).register()

    let games = try await twitch.request(endpoint: .getGames(gameIDs: ["33214"])).data

    XCTAssertEqual(games.count, 1)
    XCTAssert(games.contains(where: { $0.id == "33214" }))
  }

  func testGetTopGames() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/games/top?first=1")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getTopGamesJSON]
    ).register()

    let result = try await twitch.request(endpoint: .getTopGames(limit: 1))

    XCTAssertEqual(result.pagination?.cursor, "eyJiIjpudWxsLCJhIjp7Ik9mZnNldCI6MjB9fQ==")

    XCTAssertEqual(result.data.count, 1)
    XCTAssert(result.data.contains(where: { $0.id == "493057" }))
  }
}
