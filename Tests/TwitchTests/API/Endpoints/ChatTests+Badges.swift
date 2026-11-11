import Foundation
import Testing

@testable import Twitch

extension ChatTests {
  @Test
  func getChannelBadges() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/chat/badges?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getChannelBadgesJSON)

    let badgeSets =
      (try await harness.twitch.helix(
        for: .getChannelBadges(of: "1234")
      )).value

    #expect(badgeSets.count == 2)

    #expect(
      badgeSets.first?.badges.first?.images.url1x.absoluteString
        == "https://static-cdn.jtvnw.net/badges/v1/743a0f3b-84b3-450b-96a0-503d7f4a9764/1"
    )
  }

  @Test
  func getGlobalBadges() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/chat/badges/global"))

    await harness.session.stub(
      url: url,
      body: MockedData.getGlobalBadgesJSON)

    let badgeSets = (try await harness.twitch.helix(for: .getGlobalBadges())).value

    #expect(badgeSets.count == 1)

    #expect(
      badgeSets.first?.badges.first?.images.url1x.absoluteString
        == "https://static-cdn.jtvnw.net/badges/v1/b817aba4-fad8-49e2-b88a-7cc744dfa6ec/1"
    )
  }
}
