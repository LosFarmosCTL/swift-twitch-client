import Foundation

extension TwitchClient {
  public static func helixTask<R: Sendable, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<
      R, H, HelixEndpointResponseTypes.Void
    >,
    credentials: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default),
    completionHandler: @escaping @Sendable (HelixError?) -> Void
  ) {
    Task {
      do {
        try await Self.helix(
          endpoint: endpoint,
          credentials: credentials,
          urlSession: urlSession)
        completionHandler(nil)
      } catch let error as HelixError {
        completionHandler(error)
      }
    }
  }

  public static func helixTask<R: Sendable, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Normal>,
    credentials: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default),
    completionHandler: @escaping @Sendable (Result<R, HelixError>) -> Void
  ) {
    Task {
      do {
        let result = try await Self.helix(
          endpoint: endpoint,
          credentials: credentials,
          urlSession: urlSession)
        completionHandler(.success(result))
      } catch let error as HelixError {
        completionHandler(.failure(error))
      }
    }
  }

  public static func helixTask<R: Sendable, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Raw>,
    credentials: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default),
    completionHandler: @escaping @Sendable (Result<R, HelixError>) -> Void
  ) {
    Task {
      do {
        let result = try await Self.helix(
          endpoint: endpoint,
          credentials: credentials,
          urlSession: urlSession)
        completionHandler(.success(result))
      } catch let error as HelixError {
        completionHandler(.failure(error))
      }
    }
  }

  public func helixTask<R, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<
      R, H, HelixEndpointResponseTypes.Void
    >,
    completionHandler: @escaping @Sendable (HelixError?) -> Void
  ) {
    Task {
      do {
        try await self.helix(endpoint: endpoint)
        completionHandler(nil)
      } catch let error as HelixError {
        completionHandler(error)
      }
    }
  }

  public func helixTask<R, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Normal>,
    completionHandler: @escaping @Sendable (Result<R, HelixError>) -> Void
  ) {
    Task {
      do {
        let result = try await self.helix(endpoint: endpoint)
        completionHandler(.success(result))
      } catch let error as HelixError {
        completionHandler(.failure(error))
      }
    }
  }

  public func helixTask<R, H: Sendable & Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Raw>,
    completionHandler: @escaping @Sendable (Result<R, HelixError>) -> Void
  ) {
    Task {
      do {
        let result = try await self.helix(endpoint: endpoint)
        completionHandler(.success(result))
      } catch let error as HelixError {
        completionHandler(.failure(error))
      }
    }
  }
}
