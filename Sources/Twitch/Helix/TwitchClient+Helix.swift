import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

#if canImport(Combine)
  import Combine
#endif

extension TwitchClient {
  // MARK: - Async methods

  public func helix<R, H: Decodable>(
    endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Void>
  ) async throws {
    let data = try await self.data(for: endpoint)

    guard data.isEmpty else {
      throw HelixError.nonEmptyResponse(responseData: data)
    }
  }

  public func helix<R, H: Decodable>(
    endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Normal>
  ) async throws -> R {
    let data = try await self.data(for: endpoint)
    let response = try self.decode(data) as HelixResponse<H>

    return try endpoint.makeResponse(from: response)
  }

  // MARK: - Callback methods

  public func helixTask<R, H: Decodable>(
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

  public func helixTask<R, H: Decodable>(
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

  // MARK: - Combine methods

  #if canImport(Combine)

    public func helixPublisher<R, H: Decodable>(
      for endpoint: HelixEndpoint<
        R, H, HelixEndpointResponseTypes.Void
      >
    ) -> AnyPublisher<Void, HelixError> {
      return Future { promise in
        Task {
          do {
            try await self.helix(endpoint: endpoint)
            promise(.success(()))
          } catch let error as HelixError {
            promise(.failure(error))
          }
        }
      }.eraseToAnyPublisher()
    }

    public func helixPublisher<R, H: Decodable>(
      for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Normal>
    ) -> AnyPublisher<R, HelixError> {
      return Future { promise in
        Task {
          do {
            let result = try await self.helix(endpoint: endpoint)
            promise(.success(result))
          } catch let error as HelixError {
            promise(.failure(error))
          }
        }
      }.eraseToAnyPublisher()
    }

  #endif

  // MARK: - Networking implementation

  private func data(
    for endpoint: HelixEndpoint<some Any, some Decodable, some HelixEndpointResponseType>
  ) async throws -> Data {
    let request = endpoint.makeRequest(using: self.authentication, encoder: self.encoder)

    let (data, response): (Data, URLResponse)
    do {
      (data, response) = try await self.network.data(for: request)
    } catch {
      throw HelixError.networkError(wrapped: error)
    }

    // since we are always using an http(s) url, we can force cast the response
    // swiftlint:disable:next force_cast
    let httpResponse = response as! HTTPURLResponse
    try self.validate(data: data, response: httpResponse)

    return data
  }

  private func validate(data: Data, response: HTTPURLResponse) throws {
    let statusCode = response.statusCode

    guard (200..<300) ~= statusCode else {
      let errorResponse = try? self.decoder.decode(HelixErrorResponse.self, from: data)

      guard let errorResponse else {
        throw HelixError.parsingErrorFailed(status: statusCode, responseData: data)
      }

      throw HelixError.twitchError(
        name: errorResponse.error, status: errorResponse.status,
        message: errorResponse.message)
    }
  }

  private func decode<R>(_ data: Data) throws -> HelixResponse<R> {
    let response = try? self.decoder.decode(HelixResponse<R>.self, from: data)

    guard let response else {
      throw HelixError.parsingResponseFailed(responseData: data)
    }

    return response
  }
}
