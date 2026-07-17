import Foundation
import Testing

@testable import Twitch

struct EntitlementsTests {
  private let harness = HelixTestHarness()

  @Test
  func getDropsEntitlements() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/entitlements/drops?user_id=25009227&game_id=33214&first=3"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getDropsEntitlementsJSON)

    let (entitlements, cursor) = try await harness.twitch.helix(
      endpoint: .getDropsEntitlements(
        userID: "25009227", gameID: "33214", limit: 3))

    #expect(cursor == "eyJiIjpudWxsLCJhIjp7IkN1cnNvciI6MX0")

    #expect(entitlements.count == 3)
    let first = try #require(entitlements.first)
    #expect(first.id == "fb78259e-fb81-4d1b-8333-34a06ffc24c0")
    #expect(first.benefitID == "74c52265-e214-48a6-91b9-23b6014e8041")
    #expect(first.userID == "25009227")
    #expect(first.gameID == "33214")
    #expect(first.fulfillmentStatus == .claimed)
    #expect(first.timestamp.formatted(.iso8601) == "2019-01-28T04:17:53Z")
    #expect(first.lastUpdated.formatted(.iso8601) == "2019-01-28T04:17:53Z")
  }

  @Test
  func updateDropsEntitlements() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/entitlements/drops"))

    await harness.session.stub(
      url: url,
      method: "PATCH",
      body: MockedData.updateDropsEntitlementsJSON)

    let results = try await harness.twitch.helix(
      endpoint: .updateDropsEntitlements(
        entitlementIDs: [
          "fb78259e-fb81-4d1b-8333-34a06ffc24c0",
          "862750a5-265e-4ab6-9f0a-c64df3d54dd0",
          "d8879baa-3966-4d10-8856-15fdd62cce02",
          "9a290126-7e3b-4f66-a9ae-551537893b65",
        ],
        fulfillmentStatus: .fulfilled))

    #expect(results.count == 3)
    #expect(results.first?.status == .success)
    #expect(results.first?.ids.count == 2)
    #expect(results[1].status == .unauthorized)
    #expect(results[1].ids == ["d8879baa-3966-4d10-8856-15fdd62cce02"])
    #expect(results[2].status == .updateFailed)
    #expect(results[2].ids == ["9a290126-7e3b-4f66-a9ae-551537893b65"])
  }
}
