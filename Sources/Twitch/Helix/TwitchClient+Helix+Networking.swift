import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension TwitchClient {
  internal static func response(
    for endpoint: HelixEndpoint<
      some Any,
      some Sendable & Decodable,
      some HelixEndpointResponseType
    >,
    credentials: TwitchCredentials,
    network: NetworkSession,
    encoder: JSONEncoder = TwitchClient.makeEncoder(),
    decoder: JSONDecoder = TwitchClient.makeDecoder()
  ) async throws -> (data: Data, metadata: HelixResponseMetadata) {
    try Task.checkCancellation()

    let request: URLRequest
    do {
      request = try endpoint.makeRequest(using: credentials, encoder: encoder)
    } catch let error as TwitchAuthenticationError {
      throw HelixError.authenticationError(error)
    } catch {
      throw HelixError.unexpectedError(wrapped: error)
    }

    let (data, response): (Data, HTTPURLResponse)
    do {
      (data, response) = try await network.data(for: request)
    } catch let error as URLError where error.code == .cancelled {
      throw CancellationError()
    } catch let error as CancellationError {
      throw error
    } catch {
      throw HelixError.networkError(wrapped: error)
    }

    try Task.checkCancellation()

    let metadata = HelixResponseMetadata(response: response)
    try Self.validate(data: data, metadata: metadata, decoder: decoder)

    return (data, metadata)
  }

  internal static func validate(
    data: Data,
    metadata: HelixResponseMetadata,
    decoder: JSONDecoder
  ) throws {
    let statusCode = metadata.statusCode

    guard (200..<300) ~= statusCode else {
      let errorResponse = try? decoder.decode(HelixErrorResponse.self, from: data)
      if statusCode == 429 {
        throw HelixError.rateLimited(
          HelixRateLimitError(
            metadata: metadata, name: errorResponse?.error,
            message: errorResponse?.message, responseData: data))
      }

      guard let errorResponse else {
        throw HelixError.parsingErrorFailed(status: statusCode, responseData: data)
      }

      throw HelixError.twitchError(
        name: errorResponse.error, status: errorResponse.status,
        message: errorResponse.message)
    }
  }

  internal static func decode<R>(
    _ data: Data, decoder: JSONDecoder = TwitchClient.makeDecoder()
  ) throws
    -> DecodedHelixResponse<R>
  {
    let decoded = try? decoder.decode(HelixResponsePayload<R>.self, from: data)

    guard let decoded else {
      throw HelixError.parsingResponseFailed(responseData: data)
    }

    return DecodedHelixResponse(payload: decoded, rawData: data)
  }
}
