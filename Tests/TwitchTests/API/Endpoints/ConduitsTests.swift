import Foundation
import Testing

@testable import Twitch

struct ConduitsTests {
  private let harness = HelixTestHarness()

  @Test
  func getConduits() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/eventsub/conduits"))

    await harness.session.stub(
      url: url,
      body: MockedData.getConduitsJSON)

    let conduits = try await harness.twitch.helix(endpoint: .getConduits())

    #expect(conduits.count == 2)
    #expect(conduits.first?.id == "26b1c993-bfcf-44d9-b876-379dacafe75a")
    #expect(conduits.first?.shardCount == 15)
  }

  @Test
  func createConduit() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/eventsub/conduits"))

    await harness.session.stub(
      url: url,
      method: "POST",
      body: MockedData.createConduitJSON)

    let conduit = try await harness.twitch.helix(endpoint: .createConduit(shardCount: 5))

    #expect(conduit.id == "bfcfc993-26b1-b876-44d9-afe75a379dac")
    #expect(conduit.shardCount == 5)
  }

  @Test
  func updateConduit() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/eventsub/conduits"))

    await harness.session.stub(
      url: url,
      method: "PATCH",
      body: MockedData.updateConduitJSON)

    let conduit = try await harness.twitch.helix(
      endpoint: .updateConduit(id: "bfcfc993-26b1-b876-44d9-afe75a379dac", shardCount: 5))

    #expect(conduit.id == "bfcfc993-26b1-b876-44d9-afe75a379dac")
    #expect(conduit.shardCount == 5)
  }

  @Test
  func deleteConduit() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/eventsub/conduits?id=bfcfc993-26b1-b876-44d9-afe75a379dac"
      ))

    await harness.session.stub(
      url: url,
      method: "DELETE",
      status: 204)

    try await harness.twitch.helix(
      endpoint: .deleteConduit(id: "bfcfc993-26b1-b876-44d9-afe75a379dac"))
  }

  @Test
  func getConduitShards() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/eventsub/conduits/shards?conduit_id=bfcfc993-26b1-b876-44d9-afe75a379dac"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getConduitShardsJSON)

    let (shards, cursor) = try await harness.twitch.helix(
      endpoint: .getConduitShards(conduitID: "bfcfc993-26b1-b876-44d9-afe75a379dac"))

    #expect(cursor == nil)
    #expect(shards.count == 5)
    #expect(shards[0].id == "0")
    #expect(shards[0].status == "enabled")
    #expect(shards[0].transport.method == "webhook")
    #expect(shards[0].transport.callback == "https://this-is-a-callback.com")
    #expect(shards[0].transport.sessionID == nil)

    #expect(shards[2].transport.method == "websocket")
    #expect(shards[2].transport.sessionID == "9fd5164a-a958-4c60-b7f4-6a7202506ca0")
    #expect(shards[2].transport.connectedAt != nil)

    #expect(shards[4].status == "websocket_disconnected")
    #expect(shards[4].transport.disconnectedAt != nil)
  }

  @Test
  func updateConduitShards() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/eventsub/conduits/shards"))

    await harness.session.stub(
      url: url,
      method: "PATCH",
      body: MockedData.updateConduitShardsJSON)

    let response = try await harness.twitch.helix(
      endpoint: .updateConduitShards(
        conduitID: "bfcfc993-26b1-b876-44d9-afe75a379dac",
        shards: [
          .init(
            id: "0",
            transport: .webhook(
              callback: "https://this-is-a-callback.com", secret: "s3cre7")),
          .init(
            id: "1",
            transport: .webhook(
              callback: "https://this-is-a-callback-2.com", secret: "s3cre7")),
        ]))

    #expect(response.shards.count == 2)
    #expect(response.shards.first?.id == "0")
    #expect(response.shards.first?.status == "enabled")
    #expect(response.shards.first?.transport.callback == "https://this-is-a-callback.com")

    #expect(response.errors.count == 1)
    #expect(response.errors.first?.id == "3")
    #expect(response.errors.first?.code == "invalid_parameter")
  }
}
