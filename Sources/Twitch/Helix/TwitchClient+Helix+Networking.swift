import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension TwitchClient {
  internal nonisolated(nonsending) static func response(
    for endpoint: HelixEndpoint<some Any>,
    credentials: TwitchCredentials?,
    network: NetworkSession,
    encoder: JSONEncoder,
    beforeDispatch: (() throws -> Void)?
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

    try beforeDispatch?()
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
    return (data, metadata)
  }

  internal static func validate(
    data: Data,
    metadata: HelixResponseMetadata,
    decoder: JSONDecoder,
    onMalformedErrorBody: (any Error) -> Void
  ) throws {
    let statusCode = metadata.statusCode

    guard !(200..<300).contains(statusCode) else { return }

    let errorResponse: HelixErrorResponse
    do {
      errorResponse = try decoder.decode(HelixErrorResponse.self, from: data)
    } catch is CancellationError {
      throw CancellationError()
    } catch {
      if !(statusCode == 429 && data.isEmpty) {
        onMalformedErrorBody(error)
      }

      if statusCode == 429 {
        throw HelixError.rateLimited(
          .init(metadata: metadata, name: nil, message: nil, responseData: data))
      }

      throw HelixError.parsingErrorFailed(
        status: statusCode,
        failure: .init(underlyingError: error, responseData: data, metadata: metadata))
    }

    if statusCode == 429 {
      throw HelixError.rateLimited(
        .init(
          metadata: metadata, name: errorResponse.error,
          message: errorResponse.message, responseData: data))
    }

    throw HelixError.twitchError(
      name: errorResponse.error, status: errorResponse.status, message: errorResponse.message)
  }
}
