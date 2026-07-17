import Foundation
import Testing

@testable import Twitch

struct PollsTests {
  private let harness = HelixTestHarness()

  @Test
  func getPolls() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/polls?broadcaster_id=1234&id=ed961efd-8a3f-4cf5-a9d0-e616c590cd2a"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getPollsJSON)

    let (polls, cursor) = try await harness.twitch.helix(
      endpoint: .getPolls(filterIDs: ["ed961efd-8a3f-4cf5-a9d0-e616c590cd2a"]))

    #expect(polls.count == 1)
    #expect(cursor == nil)

    let poll = polls.first
    #expect(poll?.id == "ed961efd-8a3f-4cf5-a9d0-e616c590cd2a")
    #expect(poll?.broadcasterID == "55696719")
    #expect(poll?.title == "Heads or Tails?")
    #expect(poll?.choices.count == 2)
    #expect(poll?.choices.first?.title == "Heads")
    #expect(poll?.status == .active)
    #expect(poll?.duration == 1800)
    #expect(poll?.startedAt.formatted(.iso8601) == "2021-03-19T06:08:33Z")
    #expect(poll?.endedAt == nil)
  }

  @Test
  func createPoll() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/polls"))

    await harness.session.stub(
      url: url,
      method: "POST",
      body: MockedData.createPollJSON)

    let poll = try await harness.twitch.helix(
      endpoint: .createPoll(
        title: "Heads or Tails?",
        choices: ["Heads", "Tails"],
        duration: 1800,
        channelPointsVotingEnabled: true,
        channelPointsPerVote: 100))

    #expect(poll.id == "ed961efd-8a3f-4cf5-a9d0-e616c590cd2a")
    #expect(poll.broadcasterID == "141981764")
    #expect(poll.channelPointsVotingEnabled == true)
    #expect(poll.channelPointsPerVote == 100)
    #expect(poll.status == .active)
  }

  @Test
  func endPoll() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/polls"))

    await harness.session.stub(
      url: url,
      method: "PATCH",
      body: MockedData.endPollJSON)

    let poll = try await harness.twitch.helix(
      endpoint: .endPoll(
        id: "ed961efd-8a3f-4cf5-a9d0-e616c590cd2a",
        status: .terminated))

    #expect(poll.id == "ed961efd-8a3f-4cf5-a9d0-e616c590cd2a")
    #expect(poll.status == .terminated)
    #expect(poll.endedAt?.formatted(.iso8601) == "2021-03-19T06:11:26Z")
  }
}
