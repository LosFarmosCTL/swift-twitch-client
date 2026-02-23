import Testing

@testable import Twitch

@Suite("EventSub Whisper Events")
struct EventSubWhisperTests {
  let harness = EventTestHarness()

  @Test("Should decode whisperReceived event")
  func testWhisperReceivedEvent() async throws {
    let message = try await harness.testEvent(
      .whisperReceived(userID: "111"),
      with: MockedMessages.whisperReceived,
      requiringCondition: ["user_id": "111"])

    let received = try #require(message)
    #expect(received.fromUserID == "423374343")
    #expect(received.fromUserLogin == "glowillig")
    #expect(received.fromUserName == "glowillig")
    #expect(received.toUserID == "424596340")
    #expect(received.toUserLogin == "quotrok")
    #expect(received.toUserName == "quotrok")
    #expect(received.whisperID == "some-whisper-id")
    #expect(received.whisper == "a secret")
  }
}
