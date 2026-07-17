import Foundation
import Testing

@testable import Twitch

struct ChannelPointsTests {
  private let harness = HelixTestHarness()

  @Test
  func getCustomRewards() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id=1234"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getCustomRewardsJSON)

    let rewards = try await harness.twitch.helix(endpoint: .getCustomRewards())

    #expect(rewards.count == 1)
    #expect(rewards.first?.id == "92af127c-7326-4483-a52b-b0da0be61c01")
    #expect(rewards.first?.title == "game analysis")
    #expect(rewards.first?.cost == 50000)
    #expect(
      rewards.first?.defaultImage?.url2x
        == "https://static-cdn.jtvnw.net/custom-reward-images/default-2.png")
  }

  @Test
  func createCustomReward() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id=1234"
      ))

    await harness.session.stub(
      url: url,
      method: "POST",
      body: MockedData.createCustomRewardJSON)

    let reward = try await harness.twitch.helix(
      endpoint: .createCustomReward(title: "game analysis 1v1", cost: 50000))

    #expect(reward.broadcasterID == "274637212")
    #expect(reward.id == "afaa7e34-6b17-49f0-a19a-d1e76eaaf673")
    #expect(reward.title == "game analysis 1v1")
    #expect(reward.isEnabled == true)
  }

  @Test
  func updateCustomReward() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id=1234&id=92af127c-7326-4483-a52b-b0da0be61c01"
      ))

    await harness.session.stub(
      url: url,
      method: "PATCH",
      body: MockedData.updateCustomRewardJSON)

    let reward = try await harness.twitch.helix(
      endpoint: .updateCustomReward(
        "92af127c-7326-4483-a52b-b0da0be61c01",
        isEnabled: false))

    #expect(reward.id == "92af127c-7326-4483-a52b-b0da0be61c01")
    #expect(reward.isEnabled == false)
    #expect(reward.cost == 30000)
    #expect(reward.maxPerStreamSetting.isEnabled == true)
    #expect(reward.maxPerStreamSetting.maxPerStream == 60)
  }

  @Test
  func deleteCustomReward() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id=1234&id=92af127c-7326-4483-a52b-b0da0be61c01"
      ))

    await harness.session.stub(
      url: url,
      method: "DELETE",
      status: 204)

    try await harness.twitch.helix(
      endpoint: .deleteCustomReward("92af127c-7326-4483-a52b-b0da0be61c01"))
  }

  @Test
  func getCustomRewardRedemptions() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/channel_points/custom_rewards/redemptions?broadcaster_id=1234&reward_id=92af127c-7326-4483-a52b-b0da0be61c01&status=CANCELED"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getCustomRewardRedemptionsJSON)

    let (redemptions, cursor) = try await harness.twitch.helix(
      endpoint: .getCustomRewardRedemptions(
        rewardID: "92af127c-7326-4483-a52b-b0da0be61c01",
        status: .canceled))

    #expect(redemptions.count == 1)
    #expect(redemptions.first?.id == "17fa2df1-ad76-4804-bfa5-a40ef63efe63")
    #expect(redemptions.first?.status == .canceled)
    #expect(redemptions.first?.reward.title == "game analysis")
    #expect(
      cursor
        == "eyJiIjpudWxsLCJhIjp7IkN1cnNvciI6Ik1UZG1ZVEprWmpFdFlXUTNOaTAwT0RBMExXSm1ZVFV0WVRRd1pXWTJNMlZtWlRZelgxOHlNREl3TFRBM0xUQXhWREU0T2pNM09qTXlMakl6TXpFeU56RTFOMW89In19"
    )
  }

  @Test
  func updateRedemptionStatus() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/channel_points/custom_rewards/redemptions?broadcaster_id=1234&reward_id=92af127c-7326-4483-a52b-b0da0be61c01&id=17fa2df1-ad76-4804-bfa5-a40ef63efe63"
      ))

    await harness.session.stub(
      url: url,
      method: "PATCH",
      body: MockedData.updateRedemptionStatusJSON)

    let redemption = try await harness.twitch.helix(
      endpoint: .updateRedemptionStatus(
        ["17fa2df1-ad76-4804-bfa5-a40ef63efe63"],
        rewardID: "92af127c-7326-4483-a52b-b0da0be61c01",
        status: .canceled))

    #expect(redemption.id == "17fa2df1-ad76-4804-bfa5-a40ef63efe63")
    #expect(redemption.status == .canceled)
    #expect(redemption.userID == "274637212")
    #expect(redemption.reward.cost == 50000)
  }
}
