import Testing

@testable import Twitch

@Suite("EventSub Stream Events")
struct EventSubStreamTests {
  let harness = EventTestHarness()

  @Test("Should decode streamOnline event")
  func testStreamOnlineEvent() async throws {
    let message = try await harness.testEvent(
      .streamOnline(broadcasterID: "111"),
      with: MockedMessages.streamOnline,
      requiringCondition: ["broadcaster_user_id": "111"])

    let received = try #require(message)
    #expect(received.id == "9001")
    #expect(received.broadcasterID == "1337")
    #expect(received.broadcasterLogin == "cool_user")
    #expect(received.broadcasterName == "Cool_User")
    #expect(received.type == .live)
    #expect(received.startedAt == "2020-10-11T10:11:12.123Z")
  }

  @Test("Should decode streamOffline event")
  func testStreamOfflineEvent() async throws {
    let message = try await harness.testEvent(
      .streamOffline(broadcasterID: "111"),
      with: MockedMessages.streamOffline,
      requiringCondition: ["broadcaster_user_id": "111"])

    let received = try #require(message)
    #expect(received.broadcasterID == "1337")
    #expect(received.broadcasterLogin == "cool_user")
    #expect(received.broadcasterName == "Cool_User")
  }
}
