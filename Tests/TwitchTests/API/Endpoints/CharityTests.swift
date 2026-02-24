import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class CharityTests: XCTestCase {
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

  func testGetCharityCampaign() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/charity/campaigns?broadcaster_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getCharityCampaignJSON]
    ).register()

    let campaign = try await twitch.helix(endpoint: .getCharityCampaign())

    XCTAssertEqual(campaign?.id, "123-abc-456-def")
    XCTAssertEqual(campaign?.broadcasterID, "123456")
    XCTAssertEqual(campaign?.broadcasterLogin, "sunnysideup")
    XCTAssertEqual(campaign?.broadcasterName, "SunnySideUp")
    XCTAssertEqual(campaign?.charityName, "Example name")
    XCTAssertEqual(campaign?.charityDescription, "Example description")
    XCTAssertEqual(campaign?.charityLogo, "https://abc.cloudfront.net/ppgf/1000/100.png")
    XCTAssertEqual(campaign?.charityWebsite, "https://www.example.com")
    XCTAssertEqual(campaign?.currentAmount.value, 86000)
    XCTAssertEqual(campaign?.currentAmount.decimalPlaces, 2)
    XCTAssertEqual(campaign?.currentAmount.currency, "USD")
    XCTAssertEqual(campaign?.targetAmount?.value, 1_500_000)
    XCTAssertEqual(campaign?.targetAmount?.decimalPlaces, 2)
    XCTAssertEqual(campaign?.targetAmount?.currency, "USD")
  }

  func testGetCharityCampaignDonations() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/charity/donations?broadcaster_id=1234&first=2")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getCharityCampaignDonationsJSON]
    ).register()

    let (donations, cursor) = try await twitch.helix(
      endpoint: .getCharityCampaignDonations(limit: 2))

    XCTAssertEqual(cursor, "eyJiIjpudWxsLCJhIjp7Ik9mZnNldCI6NX19")
    XCTAssertEqual(donations.count, 2)

    let firstDonation = donations.first
    XCTAssertEqual(firstDonation?.id, "a1b2c3-aabb-4455-d1e2f3")
    XCTAssertEqual(firstDonation?.campaignID, "123-abc-456-def")
    XCTAssertEqual(firstDonation?.userID, "5678")
    XCTAssertEqual(firstDonation?.userLogin, "cool_user")
    XCTAssertEqual(firstDonation?.userName, "Cool_User")
    XCTAssertEqual(firstDonation?.amount.value, 500)
    XCTAssertEqual(firstDonation?.amount.decimalPlaces, 2)
    XCTAssertEqual(firstDonation?.amount.currency, "USD")
  }
}
