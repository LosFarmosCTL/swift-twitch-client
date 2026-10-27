import Foundation
import Testing

@testable import Twitch

struct BitsTests {
  private let harness = HelixTestHarness()

  @Test
  func getCustomPowerUps() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/bits/custom_power_ups?broadcaster_id=1234&id=reward"
      ))

    await harness.session.stub(url: url, body: MockedData.getCustomPowerUpsJSON)

    let powerUps = try await harness.twitch.helix(
      for: .getCustomPowerUps(powerUpIDs: ["reward"]))

    #expect(powerUps.count == 1)
    let powerUp = try #require(powerUps.first)
    #expect(powerUp.id == "92af127c-7326-4483-a52b-b0da0be61c02")
    #expect(powerUp.broadcasterID == "274637212")
    #expect(powerUp.title == "game analysis")
    #expect(powerUp.bits == 100)
    #expect(powerUp.image == nil)
    #expect(powerUp.defaultImage.url4x.hasSuffix("112x112.png"))
    #expect(powerUp.maxPerStreamSetting.isEnabled == false)
  }

  @Test
  func getExtensionTransactions() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/extensions/transactions?extension_id=extension&id=one&id=two&first=2&after=next"
      ))

    await harness.session.stub(url: url, body: MockedData.getExtensionTransactionsJSON)

    let (transactions, cursor) = try await harness.twitch.helix(
      for: .getExtensionTransactions(
        extensionID: "extension", transactionIDs: ["one", "two"], limit: 2, after: "next")
    )

    #expect(cursor == "cursorString")
    #expect(transactions.count == 2)
    let transaction = try #require(transactions.first)
    #expect(transaction.id == "74c52265-e214-48a6-91b9-23b6014e8041")
    #expect(transaction.broadcasterID == "439964613")
    #expect(transaction.userID == "424596340")
    #expect(transaction.productType == "BITS_IN_EXTENSION")
    #expect(transaction.productData.sku == "testSku100")
    #expect(transaction.productData.cost.amount == 100)
    #expect(transaction.productData.displayName == "Test Product 100")
  }

  @Test
  func getBitsLeaderboard() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/bits/leaderboard?count=2&period=week"))

    await harness.session.stub(
      url: url,
      body: MockedData.getBitsLeaderboardJSON)

    let leaderboard = try await harness.twitch.helix(
      for: .getBitsLeaderboard(
        count: 2, period: .week,
        startedAt: nil))

    #expect(leaderboard.total == 2)
    #expect(leaderboard.leaders.count == 2)

    #expect(leaderboard.leaders.first?.userID == "158010205")
    #expect(leaderboard.leaders.first?.rank == 1)
    #expect(leaderboard.leaders.first?.score == 12543)

    #expect(leaderboard.startDate != nil)
    #expect(leaderboard.endDate != nil)
  }

  @Test
  func getCheermotes() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/bits/cheermotes"))

    await harness.session.stub(
      url: url,
      body: MockedData.getCheermotesJSON)

    let cheermotes = try await harness.twitch.helix(for: .getCheermotes())

    #expect(cheermotes.count == 1)

    let cheermote = cheermotes.first
    #expect(cheermote?.prefix == "Cheer")
    #expect(cheermote?.type == "global_first_party")
    #expect(cheermote?.order == 1)
    #expect(cheermote?.lastUpdated.formatted(.iso8601) == "2018-05-22T00:06:04Z")
    #expect(cheermote?.isCharitable == false)

    let tier = cheermote?.tiers.first
    #expect(tier?.minBits == 1)
    #expect(tier?.id == "1")
    #expect(tier?.color == "#979797")
    #expect(tier?.canCheer == true)
    #expect(tier?.showInBitsCard == true)
    #expect(
      tier?.images.dark.animated.url1x
        == "https://d3aqoihi2n8ty8.cloudfront.net/actions/cheer/dark/animated/1/1.gif")
    #expect(
      tier?.images.light.staticImages.url2x
        == "https://d3aqoihi2n8ty8.cloudfront.net/actions/cheer/light/static/1/2.png")
  }

}
