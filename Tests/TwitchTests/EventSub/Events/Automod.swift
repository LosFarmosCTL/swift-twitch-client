import Foundation
import Testing

@testable import Twitch

@Suite("EventSub Automod Events")
struct AutomodTests {
  let twitch: TwitchClient
  let session: MockNetworkSession = MockNetworkSession()

  init() async {
    self.twitch = TwitchClient(
      authentication: .init(oAuth: "", clientID: "", userID: "", userLogin: ""),
      network: session)

    let subscriptionMessage = MockedMessages.mockEventSubSubscription
      .replacingOccurrences(of: "%type%", with: "automod.message.hold")
      .replacingOccurrences(of: "%version%", with: "2")
      .data(using: .utf8)!

    let url = URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions")!
    await session.stub(
      url: url, method: "POST",
      status: 200, headers: ["Content-Type": "application/json"],
      body: subscriptionMessage)
  }

  @Test("Should decode automodMessageHold event")
  func testAutomodMessageHoldEvent() async throws {
    await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let stream = try await twitch.eventStream(
      for: .automodMessageHold(broadcasterID: "", moderatorID: ""))

    await session.simulateIncoming(.string(MockedMessages.automodMessageHold))

    var iter = stream.makeAsyncIterator()
    let message = try await iter.next()

    _ = try #require(message)
  }

  @Test("Should decode automodMessageUpdate event")
  func testAutomodMessageUpdateEvent() async throws {
    await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let stream = try await twitch.eventStream(
      for: .automodMessageUpdate(broadcasterID: "", moderatorID: ""))

    await session.simulateIncoming(.string(MockedMessages.automodMessageUpdate))

    var iter = stream.makeAsyncIterator()
    let message = try await iter.next()

    _ = try #require(message)
  }

  @Test("Should decode automodSettingUpdate event")
  func testAutomodSettingUpdateEvent() async throws {
    await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let stream = try await twitch.eventStream(
      for: .automodSettingsUpdate(broadcasterID: "", moderatorID: ""))

    await session.simulateIncoming(.string(MockedMessages.automodSettingsUpdate))

    var iter = stream.makeAsyncIterator()
    let message = try await iter.next()

    _ = try #require(message)
  }

  @Test("Should decode automodTermsUpdate event")
  func testAutomodTermsUpdateEvent() async throws {
    await session.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let stream = try await twitch.eventStream(
      for: .automodTermsUpdate(broadcasterID: "", moderatorID: ""))

    await session.simulateIncoming(.string(MockedMessages.automodTermsUpdate))

    var iter = stream.makeAsyncIterator()
    let message = try await iter.next()

    _ = try #require(message)
  }
}
