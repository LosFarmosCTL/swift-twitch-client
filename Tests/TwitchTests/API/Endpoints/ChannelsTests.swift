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
}
