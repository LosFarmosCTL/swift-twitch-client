import Foundation
import Testing

@testable import Twitch

struct EventSubTests {
  private let harness = HelixTestHarness(
    credentials: .app(accessToken: "app-token", clientID: "client-id"))

  @Test
  func getEventSubSubscriptions() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/eventsub/subscriptions?conduit_id=conduit"))

    await harness.session.stub(
      url: url,
      body: MockedData.getEventSubSubscriptionsJSON)

    let response =
      (try await harness.twitch.helix(
        for: .getEventSubSubscriptions(filter: .conduitID("conduit")))).value

    #expect(response.total == 2)
    #expect(response.totalCost == 1)
    #expect(response.maxTotalCost == 10000)
    #expect(response.cursor == nil)

    #expect(response.subscriptions.count == 2)
    #expect(response.subscriptions.first?.isBatchingEnabled == true)
    #expect(response.subscriptions.first?.transport.conduitID == "conduit")
    #expect(response.subscriptions.last?.isBatchingEnabled == nil)
    #expect(response.subscriptions.first?.id == "26b1c993-bfcf-44d9-b876-379dacafe75a")
    #expect(response.subscriptions.first?.status == "enabled")
    #expect(response.subscriptions.first?.type == "drop.entitlement.grant")
    #expect(response.subscriptions.first?.version == "1")
    #expect(response.subscriptions.first?.cost == 1)
    #expect(response.subscriptions.first?.condition["organization_id"] == "org")

    #expect(
      response.subscriptions.last?.status == "webhook_callback_verification_pending")
    #expect(response.subscriptions.last?.type == "user.update")
    #expect(response.subscriptions.last?.cost == 0)
  }

  @Test
  func createEventSubSubscription() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions"))

    await harness.session.stub(
      url: url,
      method: "POST",
      body: MockedData.createEventSubSubscriptionJSON)

    let response =
      (try await harness.twitch.helix(
        for: .createEventSubSubscription(
          using: .webhook(callback: "https://this-is-a-callback.com", secret: "s3cre7"),
          for: .userUpdate(userID: "1234"), isBatchingEnabled: false))).value

    #expect(response.total == 1)
    #expect(response.totalCost == 1)
    #expect(response.maxTotalCost == 10000)

    #expect(response.subscription.id == "26b1c993-bfcf-44d9-b876-379dacafe75a")
    #expect(response.subscription.status == "webhook_callback_verification_pending")
    #expect(response.subscription.type == "user.update")
    #expect(response.subscription.version == "1")
    #expect(response.subscription.cost == 1)
    #expect(response.subscription.isBatchingEnabled == nil)
    let body = try #require(await harness.session.lastRequest()?.httpBody)
    let fields = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
    #expect(fields["is_batching_enabled"] as? Bool == false)
    #expect(response.subscription.transport.method == "webhook")
    #expect(response.subscription.condition["user_id"] == "1234")
  }

  @Test
  func deleteEventSubSubscription() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/eventsub/subscriptions?id=26b1c993-bfcf-44d9-b876-379dacafe75a"
      ))

    await harness.session.stub(
      url: url,
      method: "DELETE",
      status: 204)

    try await harness.twitch.helix(
      for: .deleteEventSubSubscription(
        subscriptionID: "26b1c993-bfcf-44d9-b876-379dacafe75a"))
  }
}
