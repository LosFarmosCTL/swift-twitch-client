import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension TwitchClient {
  /// Executes a one-off Helix request using explicit credentials.
  ///
  /// Use this static method when you want to make a standalone Helix call without
  /// creating a long-lived ``TwitchClient`` instance. Each call performs a single HTTP
  /// attempt with no automatic retries or rate-limit waiting.
  ///
  /// - Parameters:
  ///   - endpoint: A typed ``HelixEndpoint`` factory describing the request.
  ///   - credentials: The ``TwitchCredentials`` used to authorize the request.
  ///   - urlSession: The `URLSession` used for HTTP transport. Defaults to
  ///     `URLSession(configuration: .default)`.
  ///   - diagnostics: Opt-in decoding failure callback for this request.
  /// - Returns: A ``HelixResponse`` containing the decoded result (or `()` for empty-body
  ///   endpoints) and HTTP/rate-limit ``HelixResponseMetadata``.
  /// - Throws: ``HelixError`` for authentication, network, HTTP, rate-limit, or decoding
  ///   failures; `CancellationError` if the calling task is cancelled.
  /// - SeeAlso: <doc:Helix>, <doc:RateLimiting>, ``helix(for:)``
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

  /// Executes a Helix request using this client's current credentials.
  ///
  /// The client captures its credentials when the request begins, so a concurrent
  /// ``switchCredentials(to:chatBehavior:)`` does not disturb an in-flight call. Each
  /// invocation performs one HTTP attempt with no automatic retries or rate-limit waits.
  ///
  /// - Parameter endpoint: A typed ``HelixEndpoint`` factory describing the request.
  /// - Returns: A ``HelixResponse`` containing the decoded result (or `()` for empty-body
  ///   endpoints) and HTTP/rate-limit ``HelixResponseMetadata``.
  /// - Throws: ``HelixError`` for authentication, network, HTTP, rate-limit, or decoding
  ///   failures; `CancellationError` if the calling task is cancelled.
  /// - SeeAlso: <doc:Helix>, <doc:RateLimiting>, ``helixTask(for:completionHandler:)``
  @discardableResult
  public func helix<R: Sendable>(for endpoint: HelixEndpoint<R>) async throws -> HelixResponse<R> {
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
