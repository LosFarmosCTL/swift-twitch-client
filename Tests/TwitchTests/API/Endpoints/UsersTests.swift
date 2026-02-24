import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class UsersTests: XCTestCase {
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

  func testGetUsers() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/users?id=141981764")!

    Mock(
      url: url, contentType: .json, statusCode: 200, data: [.get: MockedData.getUsersJSON]
    ).register()

    let users = try await twitch.helix(endpoint: .getUsers(ids: ["141981764"]))

    XCTAssertEqual(users.count, 1)

    XCTAssertEqual(users.first?.id, "141981764")
    XCTAssertEqual(users.first?.broadcasterType, User.BroadcasterType.partner)
    XCTAssertNil(users.first?.email)
  }

  func testUpdateUser() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/users?description=Hello%20world!")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.put: MockedData.updateUserJSON]
    ).register()

    let user = try await twitch.helix(
      endpoint: .updateUser(description: "Hello world!"))

    XCTAssertEqual(user.description, "Hello world!")
    XCTAssertNotNil(user.email)
  }

  func testGetUserBlocklist() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/users/blocks?broadcaster_id=1234&first=2")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getUserBlocklistJSON]
    ).register()

    let blocks = try await twitch.helix(endpoint: .getBlocklist(limit: 2))

    XCTAssertEqual(blocks.count, 2)
    XCTAssert(blocks.contains(where: { $0.userID == "135093069" }))
  }

  func testGetUserExtensions() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/users/extensions/list")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getUserExtensionsJSON]
    ).register()

    let extensions = try await twitch.helix(endpoint: .getUserExtensions())

    XCTAssertEqual(extensions.count, 5)
    XCTAssert(extensions.contains(where: { $0.id == "wi08ebtatdc7oj83wtl9uxwz807l8b" }))
    XCTAssert(extensions.contains(where: { $0.types.contains(.panel) }))
  }

  func testGetUserActiveExtensions() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/users/extensions?user_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getUserActiveExtensionsJSON]
    ).register()

    let activeExtensions = try await twitch.helix(
      endpoint: .getUserActiveExtensions())

    XCTAssertEqual(activeExtensions.panel?["1"]?.name, "TopClip")
    XCTAssertEqual(activeExtensions.overlay?["1"]?.id, "zfh2irvx2jb4s60f02jq0ajm8vwgka")
    XCTAssertEqual(activeExtensions.component?["1"]?.x, 0)
    XCTAssertEqual(activeExtensions.component?["2"]?.isActive, false)
  }

  func testUpdateUserExtensions() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/users/extensions")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.put: MockedData.updateUserExtensionsJSON]
    ).register()

    let userExtensions = try await twitch.helix(
      endpoint: .updateUserExtensions(
        panel: [
          "1": ExtensionSlotUpdate(
            isActive: true, id: "rh6jq1q334hqc2rr1qlzqbvwlfl3x0", version: "1.1.0")
        ],
        overlay: [
          "1": ExtensionSlotUpdate(
            isActive: true, id: "zfh2irvx2jb4s60f02jq0ajm8vwgka", version: "1.0.19")
        ],
        component: [
          "1": ExtensionSlotUpdate(
            isActive: true, id: "lqnf3zxk0rv0g7gq92mtmnirjz2cjj", version: "0.0.1",
            x: 0, y: 0),
          "2": ExtensionSlotUpdate(isActive: false),
        ]))

    XCTAssertEqual(userExtensions.panel?["1"]?.version, "1.1.0")
    XCTAssertEqual(userExtensions.component?["1"]?.y, 0)
  }

  func testBlockUser() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/users/blocks?target_user_id=1234&reason=spam")!

    var request = URLRequest(url: url)
    request.httpMethod = "PUT"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.helix(endpoint: .block("1234", reason: .spam))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testUnblockUser() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/users/blocks?target_user_id=1234")!

    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.helix(endpoint: .unblock("1234"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }
}
