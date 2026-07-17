import Foundation
import Testing

@testable import Twitch

struct WhispersTests {
  private let harness = HelixTestHarness()

  @Test
  func sendWhisper() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/whispers?from_user_id=1234&to_user_id=4321"))

    await harness.session.stub(
      url: url,
      method: "POST",
      status: 204)

    try await harness.twitch.helix(
      endpoint: .sendWhisper(to: "4321", message: "Hello, world!"))
  }
}
