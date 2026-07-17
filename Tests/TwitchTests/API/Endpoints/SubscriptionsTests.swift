import Foundation
import Testing

@testable import Twitch

struct SubscriptionsTests {
  private let harness = HelixTestHarness()

  @Test
  func getBroadcasterSubscribers() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/subscriptions?broadcaster_id=1234&first=2"))

    await harness.session.stub(
      url: url,
      body: MockedData.getBroadcasterSubscriptionsJSON)

    let result = try await harness.twitch.helix(endpoint: .getSubscribers(limit: 2))
    let subscribers = result.subscribers

    #expect(result.total == 13)
    #expect(result.points == 13)

    #expect(result.cursor == "jnksdfyg7is8do7fv7yuwbisudg")

    #expect(subscribers.count == 2)
    #expect(subscribers.first?.gifter != nil)
    #expect(subscribers.first?.gifter?.id == "12826")
    #expect(subscribers.first?.gifter?.login == "twitch")
    #expect(subscribers.first?.gifter?.name == "Twitch")
    #expect(subscribers.last?.gifter == nil)
  }

  @Test
  func checkUserSubscription() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/subscriptions/user?broadcaster_id=1234&user_id=1234"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.checkUserSubscriptionJSON)

    let subscription = try await harness.twitch.helix(
      endpoint: .checkSubscription(to: "1234"))

    #expect(subscription?.broadcasterID == "141981764")
    #expect(subscription?.gifter?.id == "12826")
  }
}
