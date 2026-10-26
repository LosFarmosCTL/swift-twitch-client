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
    let network = URLSessionNetworkSession(session: urlSession)
    let data = try await Self.data(
      for: endpoint,
      credentials: credentials,
      network: network)

    guard data.isEmpty else {
      throw HelixError.nonEmptyResponse(responseData: data)
    }
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
    let network = URLSessionNetworkSession(session: urlSession)
    let data = try await Self.data(
      for: endpoint,
      credentials: credentials,
      network: network)

    let response = try Self.decode(data) as HelixResponse<H>
    return try endpoint.makeResponse(from: response)
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
    let network = URLSessionNetworkSession(session: urlSession)
    let data = try await Self.data(
      for: endpoint,
      credentials: credentials,
      network: network)

    return try endpoint.makeResponse(from: data)
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
    let data = try await self.data(for: endpoint)

    guard data.isEmpty else {
      throw HelixError.nonEmptyResponse(responseData: data)
    }
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
    let data = try await self.data(for: endpoint)
    let response = try Self.decode(data, decoder: self.decoder) as HelixResponse<H>

    return try endpoint.makeResponse(from: response)
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
    let data = try await self.data(for: endpoint)

    return try endpoint.makeResponse(from: data)
  }

}
