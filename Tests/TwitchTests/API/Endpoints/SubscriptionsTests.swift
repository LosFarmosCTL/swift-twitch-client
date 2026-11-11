import Foundation
import Testing

@testable import Twitch

struct SubscriptionsTests {
  private let harness = HelixTestHarness()

  @Test(arguments: [false, true])
  func getBroadcasterSubscribers(filtered: Bool) async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/subscriptions?broadcaster_id=1234&first=2"
          + (filtered ? "&user_id=1234" : "")))

    var payload = try #require(
      JSONSerialization.jsonObject(with: MockedData.getBroadcasterSubscriptionsJSON)
        as? [String: Any])
    if filtered {
      payload.removeValue(forKey: "total")
      payload.removeValue(forKey: "points")
    }
    await harness.session.stub(
      url: url, body: try JSONSerialization.data(withJSONObject: payload))

    let result =
      (try await harness.twitch.helix(
        for: .getSubscribers(userIDs: filtered ? ["1234"] : [], limit: 2))).value
    let subscribers = result.subscribers

    #expect(result.total == (filtered ? nil : 13))
    #expect(result.points == (filtered ? nil : 13))

    #expect(result.cursor == "jnksdfyg7is8do7fv7yuwbisudg")

    #expect(subscribers.count == 2)
    #expect(subscribers.first?.gifter != nil)
    #expect(subscribers.first?.gifter?.id == "12826")
    #expect(subscribers.first?.gifter?.login == "twitch")
    #expect(subscribers.first?.gifter?.displayName == "Twitch")
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

    let subscription =
      (try await harness.twitch.helix(
        for: .checkSubscription(to: "1234"))).value

    #expect(subscription?.broadcasterID == "141981764")
    #expect(subscription?.gifter?.id == "12826")
  }
}
