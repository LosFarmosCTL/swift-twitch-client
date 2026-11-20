import Foundation
import Testing

@testable import Twitch

@Suite("EventSub User Events")
struct EventSubUserTests {
  let harness = EventTestHarness()

  @Test("Should decode userUpdate event")
  func testUserUpdateEvent() async throws {
    let message = try await harness.testEvent(
      .userUpdate(userID: "111"),
      with: MockedMessages.userUpdate,
      requiringCondition: ["user_id": "111"])

    let received = try #require(message)
    #expect(received.userID == "1337")
    #expect(received.userLogin == "cool_user")
    #expect(received.userDisplayName == "Cool_User")
    #expect(received.email == "user@email.com")
    #expect(received.emailVerified == true)
    #expect(received.description == "cool description")
  }

  @Test("Custom notifications support empty and typed payloads")
  func customSubscriptionDecoding() async throws {
    let condition = ["user_id": "111"]
    let ignored: VoidEvent? = try await harness.testEvent(
      .custom(type: "user.update", version: "1", condition: condition),
      with: MockedMessages.userUpdate, requiringCondition: condition)
    _ = try #require(ignored)

    let typed = try await EventTestHarness().testEvent(
      .custom(
        type: "user.update", version: "1", condition: condition, decoding: UserUpdateEvent.self),
      with: MockedMessages.userUpdate, requiringCondition: condition)
    #expect(typed?.userID == "1337")
  }

  @Test("Custom observers share a subscription but retry decoding independently")
  func customObserversUseIndependentDecoders() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/eventsub/subscriptions"))
    let response = MockedMessages.mockEventSubSubscription
      .replacingOccurrences(of: "%type%", with: "mock")
      .replacingOccurrences(of: "%version%", with: "1")
    await harness.session.stub(url: url, method: "POST", body: Data(response.utf8))
    await harness.session.simulateIncoming(.string(MockedMessages.welcomeMessage))
    let plain = try await harness.twitch.eventStream(
      for: .custom(type: "mock", version: "1", condition: [:]))
    let typed = try await harness.twitch.eventStream(
      for: .custom(type: "mock", version: "1", condition: [:], decoding: NumberEvent.self))

    let original = MockedMessages.mockEventMessage
    let replay = original.replacingOccurrences(of: #""event": {}"#, with: #""event": {"value":7}"#)
    await harness.session.simulateIncoming(.string(original))
    await harness.session.simulateIncoming(.string(replay))
    await harness.session.simulateIncoming(
      .string(MockedMessages.customized(replay, messageID: "next")))

    var plainIterator = plain.makeAsyncIterator()
    var typedIterator = typed.makeAsyncIterator()
    let first = try #require(try await plainIterator.next())
    #expect(first.messageID == MockedMessages.defaultEventMessageID)
    #expect(try await plainIterator.next()?.messageID == "next")
    let recovered = try #require(try await typedIterator.next())
    #expect(recovered.messageID == first.messageID)
    #expect(recovered.event.value == 7)
    #expect(await harness.session.requests().filter { $0.httpMethod == "POST" }.count == 1)
    await harness.twitch.resetEventSub()
  }

  private struct NumberEvent: Event {
    let value: Int
  }
}
