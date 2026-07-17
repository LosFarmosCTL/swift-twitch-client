import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension TwitchClient {
  @discardableResult
  public static func helixTask<R: Sendable, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<
      R, H, HelixEndpointResponseTypes.Void
    >,
    credentials: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default),
    completionHandler: @escaping @Sendable (HelixError?) -> Void
  ) -> TwitchCancellable {
    makeHelixTask(
      operation: {
        try await Self.helix(
          endpoint: endpoint,
          credentials: credentials,
          urlSession: urlSession)
      },
      completionHandler: completionHandler)
  }

  @discardableResult
  public static func helixTask<R: Sendable, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Normal>,
    credentials: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default),
    completionHandler: @escaping @Sendable (Result<R, HelixError>) -> Void
  ) -> TwitchCancellable {
    makeHelixTask(
      operation: {
        try await Self.helix(
          endpoint: endpoint,
          credentials: credentials,
          urlSession: urlSession)
      },
      completionHandler: completionHandler)
  }

  @discardableResult
  public static func helixTask<R: Sendable, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Raw>,
    credentials: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default),
    completionHandler: @escaping @Sendable (Result<R, HelixError>) -> Void
  ) -> TwitchCancellable {
    makeHelixTask(
      operation: {
        try await Self.helix(
          endpoint: endpoint,
          credentials: credentials,
          urlSession: urlSession)
      },
      completionHandler: completionHandler)
  }

  @discardableResult
  public nonisolated func helixTask<R: Sendable, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<
      R, H, HelixEndpointResponseTypes.Void
    >,
    completionHandler: @escaping @Sendable (HelixError?) -> Void
  ) -> TwitchCancellable {
    makeHelixTask(
      operation: {
        try await self.helix(endpoint: endpoint)
      },
      completionHandler: completionHandler)
  }

  @discardableResult
  public nonisolated func helixTask<R: Sendable, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Normal>,
    completionHandler: @escaping @Sendable (Result<R, HelixError>) -> Void
  ) -> TwitchCancellable {
    makeHelixTask(
      operation: {
        try await self.helix(endpoint: endpoint)
      },
      completionHandler: completionHandler)
  }

  @discardableResult
  public nonisolated func helixTask<R: Sendable, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Raw>,
    completionHandler: @escaping @Sendable (Result<R, HelixError>) -> Void
  ) -> TwitchCancellable {
    makeHelixTask(
      operation: {
        try await self.helix(endpoint: endpoint)
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

private func makeHelixTask(
  operation: @escaping @Sendable () async throws -> Void,
  completionHandler: @escaping @Sendable (HelixError?) -> Void
) -> TwitchCancellable {
  makeHelixTask(operation: operation) { (result: Result<Void, HelixError>) in
    switch result {
    case .success:
      completionHandler(nil)
    case .failure(let error):
      completionHandler(error)
    }
  }
}
