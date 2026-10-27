import Foundation
import Testing

@testable import Twitch

struct UsersTests {
  private let harness = HelixTestHarness()

  @Test
  func getAuthorizationByUser() async throws {
    let harness = HelixTestHarness(
      credentials: .app(accessToken: "app-token", clientID: "client-id"))
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/authorization/users?user_id=141981764&user_id=197886470"
      ))

    await harness.session.stub(url: url, body: MockedData.getAuthorizationByUserJSON)

    let users = try await harness.twitch.helix(
      for: .getAuthorizationByUser(["141981764", "197886470"]))

    #expect(users.count == 2)
    #expect(users.first?.userID == "141981764")
    #expect(users.first?.userDisplayName == "TwitchDev")
    #expect(
      users.first?.scopes == ["bits:read", "channel:bot", "channel:manage:predictions"])
    #expect(users.first?.hasAuthorized == true)
    #expect(users.last?.userID == "197886470")
    #expect(users.last?.hasAuthorized == false)
  }

  @Test
  func getUsers() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/users?id=141981764"))

    await harness.session.stub(
      url: url,
      body: MockedData.getUsersJSON)

    let users = try await harness.twitch.helix(for: .getUsers(userIDs: ["141981764"]))

    #expect(users.count == 1)

    #expect(users.first?.id == "141981764")
    #expect(users.first?.broadcasterType == User.BroadcasterType.partner)
    #expect(users.first?.email == nil)
  }

  @Test
  func updateUser() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/users?description=Hello%20world!"))

    await harness.session.stub(
      url: url,
      method: "PUT",
      body: MockedData.updateUserJSON)

    let user = try await harness.twitch.helix(
      for: .updateUser(description: "Hello world!"))

    #expect(user.description == "Hello world!")
    #expect(user.email != nil)
  }

  @Test
  func getUserBlocklist() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/users/blocks?broadcaster_id=1234&first=2"))

    await harness.session.stub(
      url: url,
      body: MockedData.getUserBlocklistJSON)

    let blocks = try await harness.twitch.helix(for: .getUserBlocklist(limit: 2))

    #expect(blocks.count == 2)
    #expect(blocks.contains(where: { $0.userID == "135093069" }))
  }

  @Test
  func getUserExtensions() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/users/extensions/list"))

    await harness.session.stub(
      url: url,
      body: MockedData.getUserExtensionsJSON)

    let extensions = try await harness.twitch.helix(for: .getUserExtensions())

    #expect(extensions.count == 5)
    #expect(extensions.contains(where: { $0.id == "wi08ebtatdc7oj83wtl9uxwz807l8b" }))
    #expect(extensions.contains(where: { $0.types.contains(.panel) }))
  }

  @Test
  func getUserActiveExtensions() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/users/extensions?user_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getUserActiveExtensionsJSON)

    let activeExtensions = try await harness.twitch.helix(
      for: .getUserActiveExtensions())

    #expect(activeExtensions.panel?["1"]?.name == "TopClip")
    #expect(activeExtensions.overlay?["1"]?.id == "zfh2irvx2jb4s60f02jq0ajm8vwgka")
    #expect(activeExtensions.component?["1"]?.x == 0)
    #expect(activeExtensions.component?["2"]?.isActive == false)
  }

  @Test
  func updateUserExtensions() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/users/extensions"))

    await harness.session.stub(
      url: url,
      method: "PUT",
      body: MockedData.updateUserExtensionsJSON)

    let userExtensions = try await harness.twitch.helix(
      for: .updateUserExtensions(
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

    #expect(userExtensions.panel?["1"]?.version == "1.1.0")
    #expect(userExtensions.component?["1"]?.y == 0)
  }

  @Test
  func blockUser() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/users/blocks?target_user_id=1234&reason=spam"
      ))

    await harness.session.stub(
      url: url,
      method: "PUT",
      status: 204)

    try await harness.twitch.helix(for: .blockUser("1234", reason: .spam))
  }

  @Test
  func unblockUser() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/users/blocks?target_user_id=1234"))

    await harness.session.stub(
      url: url,
      method: "DELETE",
      status: 204)

    try await harness.twitch.helix(for: .unblockUser("1234"))
  }
}
