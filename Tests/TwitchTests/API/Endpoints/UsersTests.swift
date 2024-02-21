import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class UsersTests: XCTestCase {
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

  func testGetUsers() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/users?id=141981764")!

    Mock(
      url: url, contentType: .json, statusCode: 200, data: [.get: MockedData.getUsersJSON]
    ).register()

    let users = try await helix.request(endpoint: .getUsers(userIDs: ["141981764"])).data

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

    let user = try await helix.request(endpoint: .updateUser(description: "Hello world!"))

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

    let blocks = try await helix.request(
      endpoint: .getUserBlocklist(broadcasterId: "1234", limit: 2)
    ).data

    XCTAssertEqual(blocks.count, 2)
    XCTAssert(blocks.contains(where: { $0.userId == "135093069" }))
  }

  func testBlockUser() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/users/blocks?target_user_id=1234&reason=spam")!

    var request = URLRequest(url: url)
    request.httpMethod = "PUT"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await helix.request(endpoint: .blockUser(withID: "1234", reason: .spam))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testUnblockUser() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/users/blocks?target_user_id=1234")!

    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await helix.request(endpoint: .unblockUser(withID: "1234"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }
}
