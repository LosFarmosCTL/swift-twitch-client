#if canImport(Combine)
  @preconcurrency import Combine
  import Foundation
  import Testing

  @testable import Twitch

  @Suite("EventSub Publishers", .timeLimit(.minutes(1)))
  struct EventSubPublisherTests {
    private let url = URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions")!

    private func stubSubscription(
      _ network: MockNetworkSession, id: String = MockedMessages.defaultSubscriptionID
    ) async {
      await network.stub(
        url: url, method: "POST",
        body: Data(
          MockedMessages.customized(
            MockedMessages.mockEventSubSubscription, subscriptionID: id
          ).utf8))
    }

    @Test("A publisher and a subscriber without demand perform no setup")
    func lazyDemand() async throws {
      let harness = EventTestHarness()
      await stubSubscription(harness.session)
      let publisher = harness.twitch.eventPublisher(for: .mock())
      let first = DemandSubscriber<EventSubNotification<MockEvent>>()
      publisher.receive(subscriber: first)
      #expect(await harness.session.taskCount() == 0)
      #expect(await harness.session.requestCount() == 0)
      first.request(.max(1))
      let socket = await harness.session.waitForTask(at: 0)
      await socket.simulateIncoming(.string(MockedMessages.welcomeMessage))
      while await harness.session.requestCount() == 0 { await Task.yield() }
      await socket.simulateIncoming(.string(MockedMessages.mockEventMessage))
      let notification = try #require(await first.values.stream.first { _ in true })
      #expect(notification.messageID == MockedMessages.defaultEventMessageID)
      let second = DemandSubscriber<EventSubNotification<MockEvent>>()
      publisher.receive(subscriber: second)
      #expect(await harness.twitch.eventSubClient.subscriptionObserverCount == 1)
      second.cancel()
      first.cancel()
      await socket.waitForCancellation()
      #expect(
        await harness.session.requests().filter { $0.httpMethod == "POST" }.count == 1)
    }

    @Test("Helix setup failures arrive unchanged through publisher completion")
    func setupFailure() async throws {
      let harness = EventTestHarness()
      await harness.session.stub(
        url: url, method: "POST", error: URLError(.notConnectedToInternet))
      await harness.session.simulateIncoming(
        .string(MockedMessages.welcomeMessage), queue: true)
      let failures = AsyncStream<any Error>.makeStream()
      let handle = harness.twitch.eventPublisher(for: .mock()).sink(
        receiveCompletion: {
          if case .failure(let error) = $0 { failures.continuation.yield(error) }
        }, receiveValue: { _ in Issue.record("Setup failed") })
      let failure = try #require(await failures.stream.first { _ in true })
      #expect(failure is HelixError)
      let socket = await harness.session.waitForTask(at: 0)
      await socket.waitForCancellation()
      withExtendedLifetime(handle) {}
    }

    @Test("Cancellation racing an HTTP response deletes the late registration")
    func cancellationDuringRegistration() async throws {
      let harness = EventTestHarness()
      await harness.session.stub(
        url: url, method: "POST", body: Data(MockedMessages.mockEventSubSubscription.utf8)
      )
      let deleteURL = url.appending(queryItems: [
        URLQueryItem(name: "id", value: MockedMessages.defaultSubscriptionID)
      ])
      await harness.session.stub(url: deleteURL, method: "DELETE", status: 204)
      let entered = AsyncStream<Void>.makeStream()
      let release = AsyncStream<Void>.makeStream()
      let deleted = AsyncStream<Void>.makeStream()
      await harness.session.onRequest { request in
        if request.httpMethod == "POST" {
          entered.continuation.yield(())
          _ = await release.stream.first { _ in true }
        } else if request.httpMethod == "DELETE" {
          deleted.continuation.yield(())
        }
      }
      await harness.session.simulateIncoming(
        .string(MockedMessages.welcomeMessage), queue: true)
      let handle = harness.twitch.eventPublisher(for: .mock()).sink(
        receiveCompletion: { _ in Issue.record("No completion after cancellation") },
        receiveValue: { _ in Issue.record("No events after cancellation") })
      _ = await entered.stream.first { _ in true }
      handle.cancel()
      release.continuation.yield(())
      _ = await deleted.stream.first { _ in true }
      let socket = await harness.session.waitForTask(at: 0)
      await socket.waitForCancellation()
      #expect(await harness.session.requests().map(\.httpMethod) == ["POST", "DELETE"])
    }
  }

  private final class DemandSubscriber<Input: Sendable>: Combine.Subscriber,
    @unchecked Sendable
  {
    typealias Failure = any Error
    private let lock = NSLock()
    private var subscription: (any Combine.Subscription)?
    let values = AsyncStream<Input>.makeStream()

    func receive(subscription: any Combine.Subscription) {
      lock.withLock { self.subscription = subscription }
    }

    func receive(_ input: Input) -> Subscribers.Demand {
      values.continuation.yield(input)
      return .none
    }

    func receive(completion: Subscribers.Completion<any Error>) {
      if case .failure(let error) = completion {
        Issue.record("Unexpected failure: \(error)")
      }
      values.continuation.finish()
      lock.withLock { subscription = nil }
    }

    func request(_ demand: Subscribers.Demand) {
      lock.withLock { subscription }?.request(demand)
    }

    func cancel() {
      let subscription = lock.withLock {
        let subscription = self.subscription
        self.subscription = nil
        return subscription
      }
      subscription?.cancel()
    }
  }
#endif
