import Testing

@testable import Twitch

@Suite("EventSub Charity Events")
struct EventSubCharityTests {
  let harness = EventTestHarness()

  @Test("Should decode charityDonation event")
  func testCharityDonationEvent() async throws {
    let message = try await harness.testEvent(
      .charityDonation(broadcasterID: "111"),
      with: MockedMessages.charityDonation,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }

  @Test("Should decode charityCampaignStart event")
  func testCharityCampaignStartEvent() async throws {
    let message = try await harness.testEvent(
      .charityCampaignStart(broadcasterID: "111"),
      with: MockedMessages.charityCampaignStart,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }

  @Test("Should decode charityCampaignProgress event")
  func testCharityCampaignProgressEvent() async throws {
    let message = try await harness.testEvent(
      .charityCampaignProgress(broadcasterID: "111"),
      with: MockedMessages.charityCampaignProgress,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }

  @Test("Should decode charityCampaignStop event")
  func testCharityCampaignStopEvent() async throws {
    let message = try await harness.testEvent(
      .charityCampaignStop(broadcasterID: "111"),
      with: MockedMessages.charityCampaignStop,
      requiringCondition: ["broadcaster_user_id": "111"])

    _ = try #require(message)
  }
}
