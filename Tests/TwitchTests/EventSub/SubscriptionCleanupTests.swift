import Foundation
import Testing

@testable import Twitch

@Suite(.timeLimit(.minutes(1)))
struct SubscriptionCleanupTests {
  private let url = URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions")!
  private let harness = EventTestHarness()
  private var network: MockNetworkSession { harness.session }

  @Test(
    "Uncertain cleanup keeps the socket and serializes a new subscription",
    arguments: [false, true])
  func reconcileUncertainSubscription(failedCreate: Bool) async throws {
    let orphanID = "22222222-2222-2222-2222-222222222222"
    let nextID = "33333333-3333-3333-3333-333333333333"
    let deleteURL = url.appending(queryItems: [.init(name: "id", value: orphanID)])
    let lookupURL = url.appending(queryItems: [
      failedCreate
        ? .init(name: "type", value: "mock") : .init(name: "subscription_id", value: orphanID)
    ])
    let match = subscriptionBody(orphanID, version: "2")
    if failedCreate {
      await network.stub(
        url: lookupURL,
        body: Data(
          #"{"data":[],"total":1,"total_cost":0,"max_total_cost":10,"pagination":{"cursor":"next"}}"#
            .utf8))
      await network.stub(
        url: lookupURL.appending(queryItems: [.init(name: "after", value: "next")]), body: match)
    } else {
      await network.stub(url: lookupURL, body: match)
    }
    await stubSubscription(MockedMessages.defaultSubscriptionID, version: "1")
    await network.simulateIncoming(.string(MockedMessages.welcomeMessage), queue: true)
    let healthy = try await harness.twitch.eventListener(for: .mock()) { _ in }

    if failedCreate {
      await network.stub(url: url, method: "POST", body: Data("invalid JSON".utf8))
      await #expect(throws: HelixError.self) {
        _ = try await harness.twitch.eventListener(for: .mock(version: "2")) { _ in }
      }
      await network.stub(url: deleteURL, method: "DELETE", status: 204)
    } else {
      await stubSubscription(orphanID, version: "2")
      try await failFirstDelete(at: deleteURL, untilLookupAt: lookupURL)
    }

    await stubSubscription(nextID, version: "2")
    let replacement = try await harness.twitch.eventListener(for: .mock(version: "2")) { _ in }
    let requests = await network.requests()
    let lookup = try #require(requests.firstIndex { $0.url == lookupURL })
    let delete = try #require(requests.lastIndex { $0.url == deleteURL })
    let post = try #require(requests.lastIndex { $0.httpMethod == "POST" })
    #expect(lookup < delete && delete < post)
    #expect(await network.taskCount() == 1)
    #expect(await network.lastTask()?.didCancel == false)
    replacement.cancel()
    healthy.cancel()
    await harness.twitch.resetEventSub()
  }

  private func failFirstDelete(at deleteURL: URL, untilLookupAt lookupURL: URL) async throws {
    let network = network
    await network.stub(url: deleteURL, method: "DELETE", error: URLError(.networkConnectionLost))
    let deleteStarted = AsyncStream<Void>.makeStream()
    await network.onRequest { request in
      if request.httpMethod == "DELETE", request.url == deleteURL {
        deleteStarted.continuation.finish()
      } else if request.url == lookupURL {
        await network.stub(url: deleteURL, method: "DELETE", status: 204)
      }
    }
    let orphan = try await harness.twitch.eventListener(for: .mock(version: "2")) { _ in }
    orphan.cancel()
    for await _ in deleteStarted.stream {}
  }

  private func stubSubscription(_ id: String, version: String) async {
    await network.stub(url: url, method: "POST", body: subscriptionBody(id, version: version))
    await network.stub(
      url: url.appending(queryItems: [.init(name: "id", value: id)]), method: "DELETE", status: 204)
  }

  private func subscriptionBody(_ id: String, version: String) -> Data {
    Data(
      MockedMessages.customized(MockedMessages.mockEventSubSubscription, subscriptionID: id)
        .replacingOccurrences(of: "%type%", with: "mock")
        .replacingOccurrences(of: "%version%", with: version).utf8)
  }
}
