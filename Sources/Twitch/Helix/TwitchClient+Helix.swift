import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension TwitchClient {
  /// Executes a Helix request using explicit credentials.
  ///
  /// The endpoint determines the HTTP operation and response type, including empty
  /// (`Void`) and raw-body responses. Creating an endpoint performs no network I/O.
  ///
  /// - Parameters:
  ///   - endpoint: The typed request to execute.
  ///   - credentials: The credentials used to authorize the request.
  ///   - urlSession: The URL session used for network requests.
  /// - Returns: The endpoint result and metadata from its HTTP response.
  /// - Throws: `HelixError` for transport, Twitch API, or response-processing failures;
  ///   `CancellationError` when the request is cancelled.
  @discardableResult
  public static func helix<R: Sendable>(
    for endpoint: HelixEndpoint<R>,
    credentials: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default)
  ) async throws -> HelixResponse<R> {
    try await Self.helix(
      for: endpoint, credentials: credentials,
      network: URLSessionNetworkSession(session: urlSession))
  }

  /// Executes a Helix request using this client’s credentials.
  ///
  /// - Parameter endpoint: The typed request to execute.
  /// - Returns: The endpoint result and metadata from its HTTP response. Empty-body
  ///   endpoints return a `Void` value.
  /// - Throws: `HelixError` for transport, Twitch API, or response-processing failures;
  ///   `CancellationError` when the request is cancelled.
  @discardableResult
  public func helix<R>(for endpoint: HelixEndpoint<R>) async throws -> HelixResponse<R> {
    try await Self.helix(
      for: endpoint, credentials: credentials, network: network,
      encoder: encoder, decoder: decoder)
  }

  // All entry points share response handling and can use an injected transport.
  @discardableResult
  internal nonisolated(nonsending) static func helix<R>(
    for endpoint: HelixEndpoint<R>,
    credentials: TwitchCredentials,
    network: NetworkSession,
    encoder: JSONEncoder = TwitchClient.makeEncoder(),
    decoder: JSONDecoder = TwitchClient.makeDecoder(),
    beforeDispatch: (() throws -> Void)? = nil
  ) async throws -> HelixResponse<R> {
    let response = try await Self.response(
      for: endpoint, credentials: credentials, network: network,
      encoder: encoder, decoder: decoder, beforeDispatch: beforeDispatch)

    return HelixResponse(
      value: try endpoint.makeResponse(from: response.data, decoder: decoder),
      metadata: response.metadata)
  }
}
