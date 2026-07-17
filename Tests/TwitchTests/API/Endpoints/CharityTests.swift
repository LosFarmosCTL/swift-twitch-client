import Foundation
import Testing

@testable import Twitch

struct CharityTests {
  private let harness = HelixTestHarness()

  @Test
  func getCharityCampaign() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/charity/campaigns?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getCharityCampaignJSON)

    let campaign = try await harness.twitch.helix(endpoint: .getCharityCampaign())

    #expect(campaign?.id == "123-abc-456-def")
    #expect(campaign?.broadcasterID == "123456")
    #expect(campaign?.broadcasterLogin == "sunnysideup")
    #expect(campaign?.broadcasterName == "SunnySideUp")
    #expect(campaign?.charityName == "Example name")
    #expect(campaign?.charityDescription == "Example description")
    #expect(campaign?.charityLogo == "https://abc.cloudfront.net/ppgf/1000/100.png")
    #expect(campaign?.charityWebsite == "https://www.example.com")
    #expect(campaign?.currentAmount.value == 86000)
    #expect(campaign?.currentAmount.decimalPlaces == 2)
    #expect(campaign?.currentAmount.currency == "USD")
    #expect(campaign?.targetAmount?.value == 1_500_000)
    #expect(campaign?.targetAmount?.decimalPlaces == 2)
    #expect(campaign?.targetAmount?.currency == "USD")
  }

  @Test
  func getCharityCampaignDonations() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/charity/donations?broadcaster_id=1234&first=2"))

    await harness.session.stub(
      url: url,
      body: MockedData.getCharityCampaignDonationsJSON)

    let (donations, cursor) = try await harness.twitch.helix(
      endpoint: .getCharityCampaignDonations(limit: 2))

    #expect(cursor == "eyJiIjpudWxsLCJhIjp7Ik9mZnNldCI6NX19")
    #expect(donations.count == 2)

    let firstDonation = donations.first
    #expect(firstDonation?.id == "a1b2c3-aabb-4455-d1e2f3")
    #expect(firstDonation?.campaignID == "123-abc-456-def")
    #expect(firstDonation?.userID == "5678")
    #expect(firstDonation?.userLogin == "cool_user")
    #expect(firstDonation?.userName == "Cool_User")
    #expect(firstDonation?.amount.value == 500)
    #expect(firstDonation?.amount.decimalPlaces == 2)
    #expect(firstDonation?.amount.currency == "USD")
  }
}
