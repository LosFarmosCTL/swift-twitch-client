import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension TwitchClient {
  /// Executes a Helix request using explicit credentials.
  ///
  /// The endpoint determines the HTTP operation and response type. A successful response
  /// must have an empty body.
  ///
  /// - Parameters:
  ///   - endpoint: The typed request to execute.
  ///   - credentials: The credentials used to authorize the request.
  ///   - urlSession: The URL session used for network requests. Defaults to
  ///     `URLSession(configuration: .default)`.
  ///
  /// - Throws: `HelixError` for transport, Twitch API, or response-processing failures;
  ///   `CancellationError` when the request is cancelled.
  public static func helix<R: Sendable, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Void>,
    credentials: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default)
  ) async throws {
    try await Self.helix(
      for: endpoint, credentials: credentials,
      network: URLSessionNetworkSession(session: urlSession))
  }

  /// Executes a Helix request using explicit credentials.
  ///
  /// The endpoint determines the HTTP operation and response type.
  ///
  /// - Parameters:
  ///   - endpoint: The typed request to execute.
  ///   - credentials: The credentials used to authorize the request.
  ///   - urlSession: The URL session used for network requests. Defaults to
  ///     `URLSession(configuration: .default)`.
  ///
  /// - Returns: The result produced by the endpoint’s response conversion.
  ///
  /// - Throws: `HelixError` for transport, Twitch API, or response-processing failures;
  ///   `CancellationError` when the request is cancelled.
  public static func helix<R: Sendable, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Normal>,
    credentials: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default)
  ) async throws -> R {
    try await Self.helix(
      for: endpoint, credentials: credentials,
      network: URLSessionNetworkSession(session: urlSession))
  }

  /// Executes a Helix request using explicit credentials.
  ///
  /// The endpoint determines the HTTP operation and response type. The response body is
  /// converted directly without decoding a Helix JSON envelope.
  ///
  /// - Parameters:
  ///   - endpoint: The typed request to execute.
  ///   - credentials: The credentials used to authorize the request.
  ///   - urlSession: The URL session used for network requests. Defaults to
  ///     `URLSession(configuration: .default)`.
  ///
  /// - Returns: The result produced by the endpoint’s response conversion.
  ///
  /// - Throws: `HelixError` for transport, Twitch API, or response-processing failures;
  ///   `CancellationError` when the request is cancelled.
  public static func helix<R: Sendable, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Raw>,
    credentials: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default)
  ) async throws -> R {
    try await Self.helix(
      for: endpoint, credentials: credentials,
      network: URLSessionNetworkSession(session: urlSession))
  }

  /// Executes a Helix request using this client’s credentials.
  ///
  /// The endpoint determines the HTTP operation and response type. A successful response
  /// must have an empty body.
  ///
  /// - Parameters:
  ///   - endpoint: The typed request to execute.
  ///
  /// - Throws: `HelixError` for transport, Twitch API, or response-processing failures;
  ///   `CancellationError` when the request is cancelled.
  public func helix<R, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Void>
  ) async throws {
    try await Self.helix(
      for: endpoint, credentials: credentials, network: network,
      encoder: encoder, decoder: decoder)
  }

  /// Executes a Helix request using this client’s credentials.
  ///
  /// The endpoint determines the HTTP operation and response type.
  ///
  /// - Parameters:
  ///   - endpoint: The typed request to execute.
  ///
  /// - Returns: The result produced by the endpoint’s response conversion.
  ///
  /// - Throws: `HelixError` for transport, Twitch API, or response-processing failures;
  ///   `CancellationError` when the request is cancelled.
  public func helix<R, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Normal>
  ) async throws -> R {
    try await Self.helix(
      for: endpoint, credentials: credentials, network: network,
      encoder: encoder, decoder: decoder)
  }

  /// Executes a Helix request using this client’s credentials.
  ///
  /// The endpoint determines the HTTP operation and response type. The response body is
  /// converted directly without decoding a Helix JSON envelope.
  ///
  /// - Parameters:
  ///   - endpoint: The typed request to execute.
  ///
  /// - Returns: The result produced by the endpoint’s response conversion.
  ///
  /// - Throws: `HelixError` for transport, Twitch API, or response-processing failures;
  ///   `CancellationError` when the request is cancelled.
  public func helix<R, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Raw>
  ) async throws -> R {
    try await Self.helix(
      for: endpoint, credentials: credentials, network: network,
      encoder: encoder, decoder: decoder)
  }

  // All entry points share response handling and can use an injected transport.
  internal nonisolated(nonsending) static func helix<R, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Void>,
    credentials: TwitchCredentials,
    network: NetworkSession,
    encoder: JSONEncoder = TwitchClient.makeEncoder(),
    decoder: JSONDecoder = TwitchClient.makeDecoder()
  ) async throws {
    let data = try await Self.data(
      for: endpoint, credentials: credentials, network: network,
      encoder: encoder, decoder: decoder)

    guard data.isEmpty else {
      throw HelixError.nonEmptyResponse(responseData: data)
    }
  }

  internal nonisolated(nonsending) static func helix<R, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Normal>,
    credentials: TwitchCredentials,
    network: NetworkSession,
    encoder: JSONEncoder = TwitchClient.makeEncoder(),
    decoder: JSONDecoder = TwitchClient.makeDecoder()
  ) async throws -> R {
    let data = try await Self.data(
      for: endpoint, credentials: credentials, network: network,
      encoder: encoder, decoder: decoder)
    let response = try Self.decode(data, decoder: decoder) as HelixResponse<H>

    return try endpoint.makeResponse(from: response)
  }

  internal nonisolated(nonsending) static func helix<R, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Raw>,
    credentials: TwitchCredentials,
    network: NetworkSession,
    encoder: JSONEncoder = TwitchClient.makeEncoder(),
    decoder: JSONDecoder = TwitchClient.makeDecoder()
  ) async throws -> R {
    let data = try await Self.data(
      for: endpoint, credentials: credentials, network: network,
      encoder: encoder, decoder: decoder)

    return try endpoint.makeResponse(from: data)
  }

}
