import Foundation
import Testing

@testable import Twitch

struct EventTestHarness {
  let twitch: TwitchClient
  let session: MockNetworkSession = MockNetworkSession()

  init(
    authentication: TwitchCredentials = .init(
      oAuth: "", clientID: "", userID: "", userLogin: "")
  ) {
    self.twitch = TwitchClient(authentication: authentication, network: session)
  }

  func testEvent<E>(
    _ subscription: EventSubSubscription<E>,
    with data: String,
    requiringCondition: [String: String]
  )
    async throws -> E? where E: Event
  {
    let subscriptionMessage = MockedMessages.mockEventSubSubscription
      .replacingOccurrences(of: "%type%", with: subscription.type)
      .replacingOccurrences(of: "%version%", with: subscription.version)
      .data(using: .utf8)!

    let url = URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions")!
    await session.stub(
      url: url, method: "POST",
      status: 200, headers: ["Content-Type": "application/json"],
      body: subscriptionMessage)

    await session.onRequest { request in
      let body = try? JSONDecoder().decode(
        CreateEventSubRequestBody.self, from: request.httpBody ?? Data())

      #expect(body?.type == subscription.type)
      #expect(body?.version == subscription.version)

      for (key, value) in requiringCondition {
        #expect(body?.condition[key] == value)
      }
    }

    await session.simulateIncoming(.string(MockedMessages.welcomeMessage))

    let stream = try await twitch.eventStream(for: subscription)

    await session.simulateIncoming(.string(data))

    var iter = stream.makeAsyncIterator()
    return try await iter.next()
  }
}
