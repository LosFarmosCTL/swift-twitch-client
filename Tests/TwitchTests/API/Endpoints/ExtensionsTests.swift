import Foundation
import Testing

@testable import Twitch

struct ExtensionsTests {
  private let harness = HelixTestHarness()

  @Test
  func getExtensionConfigurationSegment() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/extensions/configurations?extension_id=uo6dggojyb8d6soh92zknwmi5ej1q2&segment=global"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getExtensionConfigurationSegmentJSON)

    let result = try await harness.twitch.helix(
      endpoint: .getExtensionConfigurationSegment(
        extensionID: "uo6dggojyb8d6soh92zknwmi5ej1q2",
        segments: [.global]))

    #expect(result.count == 1)
    #expect(result.first?.segment == .global)
    #expect(result.first?.content == "hello config!")
    #expect(result.first?.version == "0.0.1")
  }

  @Test
  func setExtensionConfigurationSegment() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/extensions/configurations"))

    await harness.session.stub(
      url: url,
      method: "PUT",
      status: 204)

    try await harness.twitch.helix(
      endpoint: .setExtensionConfigurationSegment(
        extensionID: "uo6dggojyb8d6soh92zknwmi5ej1q2",
        segment: .global,
        content: "hello config!",
        version: "0.0.1"))
  }

  @Test
  func sendExtensionPubSubMessage() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/extensions/pubsub"))

    await harness.session.stub(
      url: url,
      method: "POST",
      status: 204)

    try await harness.twitch.helix(
      endpoint: .sendExtensionPubSubMessage(
        target: [.broadcast],
        message: "hello world!",
        broadcasterID: "141981764"))
  }

  @Test
  func getExtensionLiveChannels() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/extensions/live?extension_id=uo6dggojyb8d6soh92zknwmi5ej1q2&first=1"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getExtensionLiveChannelsJSON)

    let (channels, cursor) = try await harness.twitch.helix(
      endpoint: .getExtensionLiveChannels(
        extensionID: "uo6dggojyb8d6soh92zknwmi5ej1q2",
        limit: 1))

    #expect(
      cursor
        == "YVc1emRHRnNiQ015TmpJek5qazVOVHBoYWpKbGRIZDFaR0Z5YjNCMGN6UTJNMkZ1TUdwM2FHWnBZbm8yYW5rNjoy"
    )
    #expect(channels.count == 3)
    #expect(channels.first?.broadcasterID == "252766116")
    #expect(channels.first?.gameID == "460630")
  }

  @Test
  func getExtensionSecrets() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/extensions/jwt/secrets?extension_id=uo6dggojyb8d6soh92zknwmi5ej1q2"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getExtensionSecretsJSON)

    let result = try await harness.twitch.helix(
      endpoint: .getExtensionSecrets(extensionID: "uo6dggojyb8d6soh92zknwmi5ej1q2"))

    #expect(result.formatVersion == 1)
    #expect(result.secrets.count == 1)
    #expect(result.secrets.first?.content == "secret")
  }

  @Test
  func createExtensionSecret() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/extensions/jwt/secrets?extension_id=uo6dggojyb8d6soh92zknwmi5ej1q2&delay=600"
      ))

    await harness.session.stub(
      url: url,
      method: "POST",
      body: MockedData.createExtensionSecretJSON)

    let result = try await harness.twitch.helix(
      endpoint: .createExtensionSecret(
        extensionID: "uo6dggojyb8d6soh92zknwmi5ej1q2",
        delay: 600))

    #expect(result.formatVersion == 1)
    #expect(result.secrets.count == 2)
    #expect(result.secrets.first?.content == "old-secret")
    #expect(result.secrets.last?.content == "new-secret")
  }

  @Test
  func sendExtensionChatMessage() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/extensions/chat?broadcaster_id=237757755"
      ))

    await harness.session.stub(
      url: url,
      method: "POST",
      status: 204)

    try await harness.twitch.helix(
      endpoint: .sendExtensionChatMessage(
        in: "237757755",
        text: "Hello",
        extensionID: "uo6dggojyb8d6soh92zknwmi5ej1q2",
        extensionVersion: "0.0.9"))
  }

  @Test
  func getExtension() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/extensions?extension_id=pgn0bjv51epi7eaekt53tovjnc82qo&extension_version=0.0.9"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getExtensionJSON)

    let result = try await harness.twitch.helix(
      endpoint: .getExtension(
        extensionID: "pgn0bjv51epi7eaekt53tovjnc82qo",
        version: "0.0.9"))

    #expect(result.id == "pgn0bjv51epi7eaekt53tovjnc82qo")
    #expect(result.name == "Official Developers Demo")
    #expect(result.state == .released)
    #expect(result.subscriptionsSupportLevel == .optional)
    #expect(result.views?.panel?.height == 300)
  }

  @Test
  func getReleasedExtension() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/extensions/released?extension_id=pgn0bjv51epi7eaekt53tovjnc82qo&extension_version=0.0.9"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getReleasedExtensionJSON)

    let result = try await harness.twitch.helix(
      endpoint: .getReleasedExtension(
        extensionID: "pgn0bjv51epi7eaekt53tovjnc82qo",
        version: "0.0.9"))

    #expect(result.id == "pgn0bjv51epi7eaekt53tovjnc82qo")
    #expect(result.name == "Official Developer Experience Demo")
    #expect(result.state == .released)
    #expect(result.subscriptionsSupportLevel == .optional)
  }

  @Test
  func getExtensionBitsProducts() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/bits/extensions?should_include_all=true"))

    await harness.session.stub(
      url: url,
      body: MockedData.getExtensionBitsProductsJSON)

    let result = try await harness.twitch.helix(
      endpoint: .getExtensionBitsProducts(includeAll: true))

    #expect(result.count == 1)
    #expect(result.first?.sku == "1010")
    #expect(result.first?.cost.amount == 990)
    #expect(result.first?.displayName == "Rusty Crate 2")
  }

  @Test
  func updateExtensionBitsProduct() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/bits/extensions"))

    await harness.session.stub(
      url: url,
      method: "PUT",
      body: MockedData.updateExtensionBitsProductJSON)

    let result = try await harness.twitch.helix(
      endpoint: .updateExtensionBitsProduct(
        sku: "1010",
        cost: .init(amount: 990, type: .bits),
        displayName: "Rusty Crate 2",
        inDevelopment: true,
        expiration: Date(timeIntervalSince1970: 1_621_329_013.397),
        isBroadcast: true))

    #expect(result.count == 1)
    #expect(result.first?.sku == "1010")
    #expect(result.first?.isBroadcast == true)
  }
}
