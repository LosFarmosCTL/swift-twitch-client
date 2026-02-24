import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class ChannelPointsTests: XCTestCase {
  private var twitch: TwitchClient!

  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    let urlSession = URLSession(configuration: configuration)

    twitch = TwitchClient(
      authentication: .init(
        oAuth: "1234567989", clientID: "abcdefghijkl", userID: "1234", userLogin: "user"),
      urlSession: urlSession)
  }

  func testGetCustomRewards() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id=1234"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getCustomRewardsJSON]
    ).register()

    let rewards = try await twitch.helix(endpoint: .getCustomRewards())

    XCTAssertEqual(rewards.count, 1)
    XCTAssertEqual(rewards.first?.id, "92af127c-7326-4483-a52b-b0da0be61c01")
    XCTAssertEqual(rewards.first?.title, "game analysis")
    XCTAssertEqual(rewards.first?.cost, 50000)
    XCTAssertEqual(
      rewards.first?.defaultImage?.url2x,
      "https://static-cdn.jtvnw.net/custom-reward-images/default-2.png")
  }

  func testCreateCustomReward() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id=1234"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.post: MockedData.createCustomRewardJSON]
    ).register()

    let reward = try await twitch.helix(
      endpoint: .createCustomReward(title: "game analysis 1v1", cost: 50000))

    XCTAssertEqual(reward.broadcasterID, "274637212")
    XCTAssertEqual(reward.id, "afaa7e34-6b17-49f0-a19a-d1e76eaaf673")
    XCTAssertEqual(reward.title, "game analysis 1v1")
    XCTAssertEqual(reward.isEnabled, true)
  }

  func testUpdateCustomReward() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id=1234&id=92af127c-7326-4483-a52b-b0da0be61c01"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.patch: MockedData.updateCustomRewardJSON]
    ).register()

    let reward = try await twitch.helix(
      endpoint: .updateCustomReward(
        "92af127c-7326-4483-a52b-b0da0be61c01",
        isEnabled: false))

    XCTAssertEqual(reward.id, "92af127c-7326-4483-a52b-b0da0be61c01")
    XCTAssertEqual(reward.isEnabled, false)
    XCTAssertEqual(reward.cost, 30000)
    XCTAssertEqual(reward.maxPerStreamSetting.isEnabled, true)
    XCTAssertEqual(reward.maxPerStreamSetting.maxPerStream, 60)
  }

  func testDeleteCustomReward() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id=1234&id=92af127c-7326-4483-a52b-b0da0be61c01"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.helix(
      endpoint: .deleteCustomReward("92af127c-7326-4483-a52b-b0da0be61c01"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testGetCustomRewardRedemptions() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/channel_points/custom_rewards/redemptions?broadcaster_id=1234&reward_id=92af127c-7326-4483-a52b-b0da0be61c01&status=CANCELED"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getCustomRewardRedemptionsJSON]
    ).register()

    let (redemptions, cursor) = try await twitch.helix(
      endpoint: .getCustomRewardRedemptions(
        rewardID: "92af127c-7326-4483-a52b-b0da0be61c01",
        status: .canceled))

    XCTAssertEqual(redemptions.count, 1)
    XCTAssertEqual(redemptions.first?.id, "17fa2df1-ad76-4804-bfa5-a40ef63efe63")
    XCTAssertEqual(redemptions.first?.status, .canceled)
    XCTAssertEqual(redemptions.first?.reward.title, "game analysis")
    XCTAssertEqual(
      cursor,
      "eyJiIjpudWxsLCJhIjp7IkN1cnNvciI6Ik1UZG1ZVEprWmpFdFlXUTNOaTAwT0RBMExXSm1ZVFV0WVRRd1pXWTJNMlZtWlRZelgxOHlNREl3TFRBM0xUQXhWREU0T2pNM09qTXlMakl6TXpFeU56RTFOMW89In19"
    )
  }

  func testUpdateRedemptionStatus() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/channel_points/custom_rewards/redemptions?broadcaster_id=1234&reward_id=92af127c-7326-4483-a52b-b0da0be61c01&id=17fa2df1-ad76-4804-bfa5-a40ef63efe63"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.patch: MockedData.updateRedemptionStatusJSON]
    ).register()

    let redemption = try await twitch.helix(
      endpoint: .updateRedemptionStatus(
        ["17fa2df1-ad76-4804-bfa5-a40ef63efe63"],
        rewardID: "92af127c-7326-4483-a52b-b0da0be61c01",
        status: .canceled))

    XCTAssertEqual(redemption.id, "17fa2df1-ad76-4804-bfa5-a40ef63efe63")
    XCTAssertEqual(redemption.status, .canceled)
    XCTAssertEqual(redemption.userID, "274637212")
    XCTAssertEqual(redemption.reward.cost, 50000)
  }
}
