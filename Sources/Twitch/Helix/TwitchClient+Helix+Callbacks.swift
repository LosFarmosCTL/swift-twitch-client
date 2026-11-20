import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension TwitchClient {
  /// Starts a callback-based one-off Helix request using explicit credentials.
  ///
  /// The completion handler is invoked from an unstructured task with no main-actor
  /// guarantee. Releasing the returned ``TwitchCancellable`` does not cancel the request;
  /// call ``TwitchCancellable/cancel()`` explicitly. Cancelled requests complete with
  /// ``HelixError/cancelled``.
  ///
  /// - Parameters:
  ///   - endpoint: A typed ``HelixEndpoint`` factory describing the request.
  ///   - credentials: The ``TwitchCredentials`` used to authorize the request.
  ///   - urlSession: The `URLSession` used for HTTP transport.
  ///   - diagnostics: Opt-in decoding failure callback for this request.
  ///   - completionHandler: Receives the ``HelixResponse`` on success or a ``HelixError``
  ///     on failure or cancellation.
  /// - Returns: A ``TwitchCancellable`` handle that cancels the underlying request task.
  /// - SeeAlso: <doc:Helix>, ``helix(for:credentials:urlSession:diagnostics:)``
  @discardableResult
  public static func helixTask<R: Sendable>(
    for endpoint: HelixEndpoint<R>,
    credentials: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default),
    diagnostics: TwitchDiagnostics = .init(),
    completionHandler: @escaping @Sendable (Result<HelixResponse<R>, HelixError>) -> Void
  ) -> TwitchCancellable {
    makeHelixTask(
      operation: {
        try await Self.helix(
          for: endpoint, credentials: credentials, urlSession: urlSession, diagnostics: diagnostics)
      },
      completionHandler: completionHandler)
  }

  /// Starts a callback-based Helix request using this client's credentials.
  ///
  /// The completion handler is invoked from an unstructured task with no main-actor
  /// guarantee. Releasing the returned ``TwitchCancellable`` does not cancel the request;
  /// call ``TwitchCancellable/cancel()`` explicitly. Cancelled requests complete with
  /// ``HelixError/cancelled``.
  ///
  /// - Parameters:
  ///   - endpoint: A typed ``HelixEndpoint`` factory describing the request.
  ///   - completionHandler: Receives the ``HelixResponse`` on success or a ``HelixError``
  ///     on failure or cancellation.
  /// - Returns: A ``TwitchCancellable`` handle that cancels the underlying request task.
  /// - SeeAlso: <doc:Helix>, ``helix(for:)``
  @discardableResult
  public nonisolated func helixTask<R: Sendable>(
    for endpoint: HelixEndpoint<R>,
    completionHandler: @escaping @Sendable (Result<HelixResponse<R>, HelixError>) -> Void
  ) -> TwitchCancellable {
    makeHelixTask(
      operation: { try await self.helix(for: endpoint) },
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

  return TwitchCancellable { task.cancel() }
}
