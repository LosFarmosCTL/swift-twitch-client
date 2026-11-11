import Foundation
import Testing

@testable import Twitch

extension ModerationTests {
  @Test
  func getBlockedTerms() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/blocked_terms?broadcaster_id=5678&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getBlockedTermsJSON)

    let (terms, cursor) =
      (try await harness.twitch.helix(
        for: .getBlockedTerms(in: "5678"))).value

    #expect(cursor == "eyJiIjpudWxsLCJhIjp7IkN1cnNvciI6I")

    #expect(terms.count == 1)
    #expect(terms.first?.text == "A phrase I'm not fond of")
    #expect(terms.first?.expiresAt == nil)
  }

  @Test
  func addBlockedTerm() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/blocked_terms?broadcaster_id=5678&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url,
      method: "POST",
      body: MockedData.getBlockedTermsJSON)

    let term =
      (try await harness.twitch.helix(
        for: .addBlockedTerm(in: "5678", text: "A phrase I'm not fond of"))).value

    #expect(term.broadcasterID == "5678")
    #expect(term.moderatorID == "1234")
    #expect(term.text == "A phrase I'm not fond of")
    #expect(term.expiresAt == nil)
  }

  @Test
  func removeBlockedTerm() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/moderation/blocked_terms?broadcaster_id=5678&moderator_id=1234&id=9876"
      ))

    await harness.session.stub(
      url: url,
      method: "DELETE",
      status: 204)

    try await harness.twitch.helix(
      for: .removeBlockedTerm(in: "5678", termID: "9876"))
  }
}
