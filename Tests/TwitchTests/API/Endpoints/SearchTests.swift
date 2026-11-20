import Foundation
import Testing

@testable import Twitch

struct SearchTests {
  private let harness = HelixTestHarness()

  @Test
  func searchCategories() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/search/categories?query=fort"))

    await harness.session.stub(
      url: url,
      body: MockedData.searchCategoriesJSON)

    let page =
      (try await harness.twitch.helix(
        for: .searchCategories(for: "fort"))).value
    let categories = page.categories
    let cursor = page.cursor

    #expect(cursor == "eyJiIjpudWxsLCJhIjp7IkN")

    #expect(categories.count == 1)
    #expect(categories.contains(where: { $0.id == "33214" }))
  }

  @Test
  func searchChannels() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/search/channels?query=loser"))

    await harness.session.stub(
      url: url,
      body: MockedData.searchChannelsJSON)

    let page =
      (try await harness.twitch.helix(
        for: .searchChannels(for: "loser"))).value
    let channels = page.channels
    let cursor = page.cursor

    #expect(cursor == nil)

    #expect(channels.count == 2)
    #expect(channels.contains(where: { $0.id == "41245072" }))
  }
}
