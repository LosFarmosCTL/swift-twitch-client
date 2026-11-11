import Foundation
import Testing

@testable import Twitch

extension ModerationTests {
  @Test
  func getBannedUsers() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/moderation/banned?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getBannedUsersJSON)

    let (bans, cursor) = (try await harness.twitch.helix(for: .getBannedUsers())).value

    #expect(cursor == "eyJiIjpudWxsLCJhIjp7IkN1cnNvciI")

    #expect(bans.count == 2)
    #expect(bans.first?.userID == "423374343")
    #expect(bans.first?.expiresAt == nil)
    #expect(bans.last?.expiresAt != nil)
  }

  @Test
  func banUser() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/bans?broadcaster_id=5678&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url,
      method: "POST",
      body: MockedData.banUserJSON)

    let ban = (try await harness.twitch.helix(for: .banUser("9876", in: "5678"))).value

    #expect(ban.broadcasterID == "5678")
    #expect(ban.moderatorID == "1234")
    #expect(ban.userID == "9876")
    #expect(ban.endTime == nil)
  }

  @Test
  func unbanUser() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/bans?broadcaster_id=5678&moderator_id=1234&user_id=9876"
      ))

    await harness.session.stub(
      url: url,
      method: "DELETE",
      status: 204)

    try await harness.twitch.helix(for: .unbanUser("9876", in: "5678"))
  }

  @Test
  func getUnbanRequests() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/unban_requests?broadcaster_id=274637212&moderator_id=1234&status=pending&first=20"
      ))

    await harness.session.stub(url: url, body: MockedData.getUnbanRequestsJSON)

    let (requests, cursor) =
      (try await harness.twitch.helix(
        for: .getUnbanRequests(in: "274637212", status: .pending, limit: 20))).value

    #expect(cursor != nil)
    #expect(requests.count == 1)
    let request = try #require(requests.first)
    #expect(request.id == "92af127c-7326-4483-a52b-b0da0be61c01")
    #expect(request.userID == "424596340")
    #expect(request.status == "pending")
    #expect(request.moderatorID == nil)
    #expect(request.moderatorLogin == nil)
    #expect(request.moderatorDisplayName == nil)
    #expect(request.resolvedAt == nil)
    #expect(request.resolutionText == nil)
  }

  @Test
  func resolveUnbanRequest() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/unban_requests?broadcaster_id=274637212&moderator_id=1234&unban_request_id=request&status=approved&resolution_text=Welcome%20back!"
      ))

    await harness.session.stub(
      url: url, method: "PATCH", body: MockedData.resolveUnbanRequestJSON)

    let request =
      (try await harness.twitch.helix(
        for: .resolveUnbanRequest(
          "request", in: "274637212", status: .approved, resolutionText: "Welcome back!")))
      .value

    #expect(request.id == "92af127c-7326-4483-a52b-b0da0be61c01")
    #expect(request.userID == "424596340")
    #expect(request.status == "approved")
    #expect(request.resolvedAt?.formatted(.iso8601) == "2022-08-09T02:07:55Z")
  }
}
