import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension TwitchClient {
  /// Starts a callback-based Helix request using explicit credentials.
  ///
  /// The endpoint determines the HTTP operation and response type. A successful response
  /// must have an empty body. The completion handler runs from an unstructured task
  /// without a main-actor delivery guarantee. Releasing the returned handle does not
  /// cancel the request.
  ///
  /// - Parameters:
  ///   - endpoint: The typed request to execute.
  ///   - credentials: The credentials used to authorize the request.
  ///   - urlSession: The URL session used for network requests. Defaults to
  ///     `URLSession(configuration: .default)`.
  ///   - completionHandler: Receives response metadata on success or the request error on failure.
  ///
  /// - Returns: A handle whose `cancel()` method cancels the request task.
  @discardableResult
  public static func helixTask<R: Sendable, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<
      R, H, HelixEndpointResponseTypes.Void
    >,
    credentials: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default),
    completionHandler:
      @escaping @Sendable (Result<HelixResponse<Void>, HelixError>) -> Void
  ) -> TwitchCancellable {
    makeHelixTask(
      operation: {
        try await Self.helix(
          for: endpoint,
          credentials: credentials,
          urlSession: urlSession)
      },
      completionHandler: completionHandler)
  }

  /// Starts a callback-based Helix request using explicit credentials.
  ///
  /// The endpoint determines the HTTP operation and response type. The completion handler
  /// runs from an unstructured task without a main-actor delivery guarantee. Releasing
  /// the returned handle does not cancel the request.
  ///
  /// - Parameters:
  ///   - endpoint: The typed request to execute.
  ///   - credentials: The credentials used to authorize the request.
  ///   - urlSession: The URL session used for network requests. Defaults to
  ///     `URLSession(configuration: .default)`.
  ///   - completionHandler: Receives the endpoint result with response metadata or a `HelixError`.
  ///
  /// - Returns: A handle whose `cancel()` method cancels the request task.
  @discardableResult
  public static func helixTask<R: Sendable, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Normal>,
    credentials: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default),
    completionHandler: @escaping @Sendable (Result<HelixResponse<R>, HelixError>) -> Void
  ) -> TwitchCancellable {
    makeHelixTask(
      operation: {
        try await Self.helix(
          for: endpoint,
          credentials: credentials,
          urlSession: urlSession)
      },
      completionHandler: completionHandler)
  }

  /// Starts a callback-based Helix request using explicit credentials.
  ///
  /// The endpoint determines the HTTP operation and response type. The response body is
  /// converted directly without decoding a Helix JSON envelope. The completion handler
  /// runs from an unstructured task without a main-actor delivery guarantee. Releasing
  /// the returned handle does not cancel the request.
  ///
  /// - Parameters:
  ///   - endpoint: The typed request to execute.
  ///   - credentials: The credentials used to authorize the request.
  ///   - urlSession: The URL session used for network requests. Defaults to
  ///     `URLSession(configuration: .default)`.
  ///   - completionHandler: Receives the endpoint result with response metadata or a `HelixError`.
  ///
  /// - Returns: A handle whose `cancel()` method cancels the request task.
  @discardableResult
  public static func helixTask<R: Sendable, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Raw>,
    credentials: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default),
    completionHandler: @escaping @Sendable (Result<HelixResponse<R>, HelixError>) -> Void
  ) -> TwitchCancellable {
    makeHelixTask(
      operation: {
        try await Self.helix(
          for: endpoint,
          credentials: credentials,
          urlSession: urlSession)
      },
      completionHandler: completionHandler)
  }

  /// Starts a callback-based Helix request using this client’s credentials.
  ///
  /// The endpoint determines the HTTP operation and response type. A successful response
  /// must have an empty body. The completion handler runs from an unstructured task
  /// without a main-actor delivery guarantee. Releasing the returned handle does not
  /// cancel the request.
  ///
  /// - Parameters:
  ///   - endpoint: The typed request to execute.
  ///   - completionHandler: Receives response metadata on success or the request error on failure.
  ///
  /// - Returns: A handle whose `cancel()` method cancels the request task.
  @discardableResult
  public nonisolated func helixTask<R: Sendable, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<
      R, H, HelixEndpointResponseTypes.Void
    >,
    completionHandler:
      @escaping @Sendable (Result<HelixResponse<Void>, HelixError>) -> Void
  ) -> TwitchCancellable {
    makeHelixTask(
      operation: {
        try await self.helix(for: endpoint)
      },
      completionHandler: completionHandler)
  }

  /// Starts a callback-based Helix request using this client’s credentials.
  ///
  /// The endpoint determines the HTTP operation and response type. The completion handler
  /// runs from an unstructured task without a main-actor delivery guarantee. Releasing
  /// the returned handle does not cancel the request.
  ///
  /// - Parameters:
  ///   - endpoint: The typed request to execute.
  ///   - completionHandler: Receives the endpoint result with response metadata or a `HelixError`.
  ///
  /// - Returns: A handle whose `cancel()` method cancels the request task.
  @discardableResult
  public nonisolated func helixTask<R: Sendable, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Normal>,
    completionHandler: @escaping @Sendable (Result<HelixResponse<R>, HelixError>) -> Void
  ) -> TwitchCancellable {
    makeHelixTask(
      operation: {
        try await self.helix(for: endpoint)
      },
      completionHandler: completionHandler)
  }

  /// Starts a callback-based Helix request using this client’s credentials.
  ///
  /// The endpoint determines the HTTP operation and response type. The response body is
  /// converted directly without decoding a Helix JSON envelope. The completion handler
  /// runs from an unstructured task without a main-actor delivery guarantee. Releasing
  /// the returned handle does not cancel the request.
  ///
  /// - Parameters:
  ///   - endpoint: The typed request to execute.
  ///   - completionHandler: Receives the endpoint result with response metadata or a `HelixError`.
  ///
  /// - Returns: A handle whose `cancel()` method cancels the request task.
  @discardableResult
  public nonisolated func helixTask<R: Sendable, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Raw>,
    completionHandler: @escaping @Sendable (Result<HelixResponse<R>, HelixError>) -> Void
  ) -> TwitchCancellable {
    makeHelixTask(
      operation: {
        try await self.helix(for: endpoint)
      },
      completionHandler: completionHandler)
  }
}

private func makeHelixTask<Success: Sendable>(
  operation: @escaping @Sendable () async throws -> Success,
  completionHandler: @escaping @Sendable (Result<Success, HelixError>) -> Void
) -> TwitchCancellable {
  let task = Task<Void, Never> {
    do {
      completionHandler(.success(try await operation()))
    } catch is CancellationError {
      completionHandler(.failure(.cancelled))
    } catch let error as HelixError {
      completionHandler(.failure(error))
    } catch {
      completionHandler(.failure(.unexpectedError(wrapped: error)))
    }
  }

  return TwitchCancellable {
    task.cancel()
  }
}
