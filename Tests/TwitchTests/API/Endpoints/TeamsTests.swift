import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class TeamsTests: XCTestCase {
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

  func testGetChannelTeams() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/teams/channel?broadcaster_id=96909659")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getChannelTeamsJSON]
    ).register()

    let teams = try await twitch.helix(
      endpoint: .getChannelTeams(for: "96909659")
    )

    XCTAssertEqual(teams.count, 1)
    XCTAssertEqual(teams.first?.id, "6358")
    XCTAssertEqual(teams.first?.teamDisplayName, "Live Coders")
    XCTAssertEqual(
      teams.first?.createdAt.formatted(.iso8601), "2019-02-11T12:09:22Z")
  }

  func testGetTeams() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/teams?id=6358")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getTeamsJSON]
    ).register()

    let teams = try await twitch.helix(endpoint: .getTeams(id: "6358"))

    XCTAssertEqual(teams.count, 1)
    XCTAssertEqual(teams.first?.teamName, "livecoders")
    XCTAssertEqual(teams.first?.users?.count, 2)
    XCTAssertEqual(teams.first?.users?.first?.userID, "278217731")
  }
}
