import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class ExtensionsTests: XCTestCase {
  private var twitch: TwitchClient!

  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    let urlSession = URLSession(configuration: configuration)

    twitch = TwitchClient(
      authentication: .init(
        oAuth: "1234567989", clientID: "abcdefghijkl", userID: "1234", userLogin: "user"),
      urlSession: urlSession)
  }

  func testGetExtensionConfigurationSegment() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/extensions/configurations?extension_id=uo6dggojyb8d6soh92zknwmi5ej1q2&segment=global"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getExtensionConfigurationSegmentJSON]
    ).register()

    let result = try await twitch.helix(
      endpoint: .getExtensionConfigurationSegment(
        extensionID: "uo6dggojyb8d6soh92zknwmi5ej1q2",
        segments: [.global]))

    XCTAssertEqual(result.count, 1)
    XCTAssertEqual(result.first?.segment, .global)
    XCTAssertEqual(result.first?.content, "hello config!")
    XCTAssertEqual(result.first?.version, "0.0.1")
  }

  func testSetExtensionConfigurationSegment() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/extensions/configurations")!

    var request = URLRequest(url: url)
    request.httpMethod = "PUT"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.helix(
      endpoint: .setExtensionConfigurationSegment(
        extensionID: "uo6dggojyb8d6soh92zknwmi5ej1q2",
        segment: .global,
        content: "hello config!",
        version: "0.0.1"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testSendExtensionPubSubMessage() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/extensions/pubsub")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.helix(
      endpoint: .sendExtensionPubSubMessage(
        target: [.broadcast],
        message: "hello world!",
        broadcasterID: "141981764"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testGetExtensionLiveChannels() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/extensions/live?extension_id=uo6dggojyb8d6soh92zknwmi5ej1q2&first=1"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getExtensionLiveChannelsJSON]
    ).register()

    let (channels, cursor) = try await twitch.helix(
      endpoint: .getExtensionLiveChannels(
        extensionID: "uo6dggojyb8d6soh92zknwmi5ej1q2",
        limit: 1))

    XCTAssertEqual(
      cursor,
      "YVc1emRHRnNiQ015TmpJek5qazVOVHBoYWpKbGRIZDFaR0Z5YjNCMGN6UTJNMkZ1TUdwM2FHWnBZbm8yYW5rNjoy"
    )
    XCTAssertEqual(channels.count, 3)
    XCTAssertEqual(channels.first?.broadcasterID, "252766116")
    XCTAssertEqual(channels.first?.gameID, "460630")
  }

  func testGetExtensionSecrets() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/extensions/jwt/secrets?extension_id=uo6dggojyb8d6soh92zknwmi5ej1q2"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getExtensionSecretsJSON]
    ).register()

    let result = try await twitch.helix(
      endpoint: .getExtensionSecrets(extensionID: "uo6dggojyb8d6soh92zknwmi5ej1q2"))

    XCTAssertEqual(result.formatVersion, 1)
    XCTAssertEqual(result.secrets.count, 1)
    XCTAssertEqual(result.secrets.first?.content, "secret")
  }

  func testCreateExtensionSecret() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/extensions/jwt/secrets?extension_id=uo6dggojyb8d6soh92zknwmi5ej1q2&delay=600"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.post: MockedData.createExtensionSecretJSON]
    ).register()

    let result = try await twitch.helix(
      endpoint: .createExtensionSecret(
        extensionID: "uo6dggojyb8d6soh92zknwmi5ej1q2",
        delay: 600))

    XCTAssertEqual(result.formatVersion, 1)
    XCTAssertEqual(result.secrets.count, 2)
    XCTAssertEqual(result.secrets.first?.content, "old-secret")
    XCTAssertEqual(result.secrets.last?.content, "new-secret")
  }

  func testSendExtensionChatMessage() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/extensions/chat?broadcaster_id=237757755"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.helix(
      endpoint: .sendExtensionChatMessage(
        in: "237757755",
        text: "Hello",
        extensionID: "uo6dggojyb8d6soh92zknwmi5ej1q2",
        extensionVersion: "0.0.9"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testGetExtension() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/extensions?extension_id=pgn0bjv51epi7eaekt53tovjnc82qo&extension_version=0.0.9"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getExtensionJSON]
    ).register()

    let result = try await twitch.helix(
      endpoint: .getExtension(
        extensionID: "pgn0bjv51epi7eaekt53tovjnc82qo",
        version: "0.0.9"))

    XCTAssertEqual(result.id, "pgn0bjv51epi7eaekt53tovjnc82qo")
    XCTAssertEqual(result.name, "Official Developers Demo")
    XCTAssertEqual(result.state, .released)
    XCTAssertEqual(result.subscriptionsSupportLevel, .optional)
    XCTAssertEqual(result.views?.panel?.height, 300)
  }

  func testGetReleasedExtension() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/extensions/released?extension_id=pgn0bjv51epi7eaekt53tovjnc82qo&extension_version=0.0.9"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getReleasedExtensionJSON]
    ).register()

    let result = try await twitch.helix(
      endpoint: .getReleasedExtension(
        extensionID: "pgn0bjv51epi7eaekt53tovjnc82qo",
        version: "0.0.9"))

    XCTAssertEqual(result.id, "pgn0bjv51epi7eaekt53tovjnc82qo")
    XCTAssertEqual(result.name, "Official Developer Experience Demo")
    XCTAssertEqual(result.state, .released)
    XCTAssertEqual(result.subscriptionsSupportLevel, .optional)
  }

  func testGetExtensionBitsProducts() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/bits/extensions")!

    Mock(
      url: url, ignoreQuery: true, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getExtensionBitsProductsJSON]
    ).register()

    let result = try await twitch.helix(
      endpoint: .getExtensionBitsProducts(includeAll: true))

    XCTAssertEqual(result.count, 1)
    XCTAssertEqual(result.first?.sku, "1010")
    XCTAssertEqual(result.first?.cost.amount, 990)
    XCTAssertEqual(result.first?.displayName, "Rusty Crate 2")
  }

  func testUpdateExtensionBitsProduct() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/bits/extensions")!

    Mock(
      url: url, ignoreQuery: true, contentType: .json, statusCode: 200,
      data: [.put: MockedData.updateExtensionBitsProductJSON]
    ).register()

    let result = try await twitch.helix(
      endpoint: .updateExtensionBitsProduct(
        sku: "1010",
        cost: .init(amount: 990, type: .bits),
        displayName: "Rusty Crate 2",
        inDevelopment: true,
        expiration: Date(timeIntervalSince1970: 1_621_329_013.397),
        isBroadcast: true))

    XCTAssertEqual(result.count, 1)
    XCTAssertEqual(result.first?.sku, "1010")
    XCTAssertEqual(result.first?.isBroadcast, true)
  }
}
