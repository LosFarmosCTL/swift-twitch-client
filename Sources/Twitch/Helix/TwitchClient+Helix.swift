import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

#if canImport(Combine)
  import Combine
#endif

extension TwitchClient {
  // MARK: - Async methods

  public func request(
    endpoint: HelixEndpoint<some Any, some Any, HelixEndpointResponseTypes.Void>
  )
    async throws
  {
    let data = try await self.data(for: endpoint)

    guard data.isEmpty else {
      let rawResponse = String(decoding: data, as: UTF8.self)
      throw HelixError.nonEmptyResponse(rawResponse: rawResponse)
    }
  }

  public func request<R, H: Decodable>(
    endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Normal>
  )
    async throws
    -> R
  {
    let data = try await self.data(for: endpoint)
    let response = try self.decode(data) as HelixResponse<H>

    return try endpoint.makeResponse(from: response)
  }

  // MARK: - Callback methods

  public func requestTask(
    for endpoint: HelixEndpoint<some Any, some Any, HelixEndpointResponseTypes.Void>,
    completionHandler: @escaping @Sendable (HelixError?) -> Void
  ) {
    Task {
      do {
        try await self.request(endpoint: endpoint)
        completionHandler(nil)
      } catch let error as HelixError {
        completionHandler(error)
      }
    }
  }

  public func requestTask<R, H: Decodable>(
    for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Normal>,
    completionHandler: @escaping @Sendable (R?, HelixError?) -> Void
  ) {
    Task {
      do {
        let result = try await self.request(endpoint: endpoint)
        completionHandler(result, nil)
      } catch let error as HelixError {
        completionHandler(nil, error)
      }
    }
  }

  // MARK: - Combine methods

  #if canImport(Combine)

    public func requestPublisher(
      for endpoint: HelixEndpoint<some Any, some Any, HelixEndpointResponseTypes.Void>
    ) -> AnyPublisher<Void, HelixError> {
      return Future { promise in
        Task {
          do {
            try await self.request(endpoint: endpoint)
            promise(.success(()))
          } catch let error as HelixError {
            promise(.failure(error))
          }
        }
      }.eraseToAnyPublisher()
    }

    public func requestPublisher<R, H: Decodable>(
      for endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Normal>
    ) -> AnyPublisher<R, HelixError> {
      return Future { promise in
        Task {
          do {
            let result = try await self.request(endpoint: endpoint)
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
    let request = endpoint.makeRequest(using: self.authentication)

    let (data, response): (Data, URLResponse)
    do {
      (data, response) = try await self.urlSession.data(for: request)
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
        let rawResponse = String(decoding: data, as: UTF8.self)

        throw HelixError.parsingErrorFailed(status: statusCode, rawResponse: rawResponse)
      }

      throw HelixError.twitchError(
        name: errorResponse.error, status: errorResponse.status,
        message: errorResponse.message)
    }
  }

  private func decode<R>(_ data: Data) throws -> HelixResponse<R> {
    let response = try? self.decoder.decode(HelixResponse<R>.self, from: data)

    guard let response else {
      let rawResponse = String(decoding: data, as: UTF8.self)
      throw HelixError.parsingResponseFailed(rawResponse: rawResponse)
    }

    return response
  }
}
