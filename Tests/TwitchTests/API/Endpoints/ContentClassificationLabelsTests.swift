import Foundation
import Testing

@testable import Twitch

struct ContentClassificationLabelsTests {
  private let harness = HelixTestHarness()

  @Test
  func getContentClassificationLabels() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/content_classification_labels?locale=en-US"))

    await harness.session.stub(
      url: url,
      body: MockedData.getContentClassificationLabelsJSON)

    let labels = try await harness.twitch.helix(
      endpoint: .getContentClassificationLabels())

    #expect(labels.count == 6)
    #expect(labels.contains(where: { $0.id == "ViolentGraphic" }))
  }
}
