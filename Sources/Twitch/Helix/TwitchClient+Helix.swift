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
  ///   - diagnostics: Opt-in decoding diagnostics for this request.
  /// - Returns: The endpoint result and metadata from its HTTP response.
  /// - Throws: `HelixError` for transport, Twitch API, or response-processing failures;
  ///   `CancellationError` when the request is cancelled.
  @discardableResult
  public static func helix<R: Sendable>(
    for endpoint: HelixEndpoint<R>,
    credentials: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default),
    diagnostics: TwitchDiagnostics = .init()
  ) async throws -> HelixResponse<R> {
    try await Self.helix(
      for: endpoint, credentials: credentials,
      network: URLSessionNetworkSession(session: urlSession), diagnostics: diagnostics)
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
      encoder: encoder, decoder: decoder, diagnostics: diagnostics)
  }

  // All entry points share response handling and can use an injected transport.
  @discardableResult
  internal nonisolated(nonsending) static func helix<R>(
    for endpoint: HelixEndpoint<R>,
    credentials: TwitchCredentials,
    network: NetworkSession,
    encoder: JSONEncoder = TwitchClient.makeEncoder(),
    decoder: JSONDecoder = TwitchClient.makeDecoder(),
    diagnostics: TwitchDiagnostics = .init(),
    beforeDispatch: (() throws -> Void)? = nil
  ) async throws -> HelixResponse<R> {
    let response = try await Self.response(
      for: endpoint, credentials: credentials, network: network,
      encoder: encoder, beforeDispatch: beforeDispatch)

    func report(
      _ stage: TwitchDecodingDiagnostic.Stage,
      _ details: @autoclosure () -> TwitchDecodingFailureDetails
    ) {
      diagnostics.report(
        .init(
          source: .helix,
          stage: stage,
          details: details(),
          payloadByteCount: response.data.count,
          metadata: response.metadata,
          requestMethod: endpoint.method,
          requestPath: endpoint.path
        )
      )
    }

    try Self.validate(data: response.data, metadata: response.metadata, decoder: decoder) {
      report(.errorResponse, .init(error: $0))
    }

    do {
      let value = try endpoint.makeResponse(
        from: response.data, metadata: response.metadata, decoder: decoder
      ) { report(.pagination, .init(error: $0)) }
      return HelixResponse(value: value, metadata: response.metadata)
    } catch let error as HelixError {
      if case .parsingResponseFailed(let failure) = error { report(.response, failure.details) }
      throw error
    }
  }
}
