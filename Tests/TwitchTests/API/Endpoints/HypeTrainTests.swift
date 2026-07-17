import Foundation
import Testing

@testable import Twitch

struct HypeTrainTests {
  private let harness = HelixTestHarness()

  @Test
  func getHypeTrainStatus() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/hypetrain/status?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getHypeTrainStatusJSON)

    let status = try await harness.twitch.helix(endpoint: .getHypeTrainStatus())

    #expect(status.current?.id == "1b0AsbInCHZW2SQFQkCzqN07Ib2")
    #expect(status.current?.broadcasterID == "1337")
    #expect(status.current?.broadcasterLogin == "cool_user")
    #expect(status.current?.broadcasterName == "Cool_User")
    #expect(status.current?.level == 2)
    #expect(status.current?.total == 700)
    #expect(status.current?.progress == 200)
    #expect(status.current?.goal == 1000)
    #expect(status.current?.type == .goldenKappa)
    #expect(status.current?.isSharedTrain == true)
    #expect(status.current?.topContributions.count == 2)
    #expect(status.current?.topContributions.first?.type == .bits)
    #expect(status.current?.topContributions.first?.total == 50)
    #expect(status.current?.sharedTrainParticipants?.count == 2)
    #expect(status.current?.startedAt.formatted(.iso8601) == "2020-07-15T17:16:03Z")
    #expect(status.current?.expiresAt.formatted(.iso8601) == "2020-07-15T17:16:11Z")
    #expect(status.allTimeHigh?.level == 6)
    #expect(status.allTimeHigh?.total == 2850)
    #expect(status.allTimeHigh?.achievedAt.formatted(.iso8601) == "2020-04-24T20:12:21Z")
    #expect(status.sharedAllTimeHigh?.level == 16)
    #expect(status.sharedAllTimeHigh?.total == 23850)
    #expect(
      status.sharedAllTimeHigh?.achievedAt.formatted(.iso8601) == "2020-04-27T20:12:21Z")
  }
}
