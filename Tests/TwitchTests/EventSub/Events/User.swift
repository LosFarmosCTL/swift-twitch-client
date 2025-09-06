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
    #expect(received.userName == "Cool_User")
    #expect(received.email == "user@email.com")
    #expect(received.emailVerified == true)
    #expect(received.description == "cool description")
  }
}
