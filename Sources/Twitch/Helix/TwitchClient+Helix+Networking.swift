import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension TwitchClient {
  internal func data(
    for endpoint: HelixEndpoint<
      some Any,
      some Sendable & Decodable,
      some HelixEndpointResponseType
    >
  ) async throws -> Data {
    try await Self.data(
      for: endpoint,
      credentials: self.authentication,
      network: self.network,
      encoder: self.encoder,
      decoder: self.decoder)
  }

  internal static func data(
    for endpoint: HelixEndpoint<
      some Any,
      some Sendable & Decodable,
      some HelixEndpointResponseType
    >,
    credentials: TwitchCredentials,
    network: NetworkSession,
    encoder: JSONEncoder = TwitchClient.makeEncoder(),
    decoder: JSONDecoder = TwitchClient.makeDecoder()
  ) async throws -> Data {
    let request = endpoint.makeRequest(using: credentials, encoder: encoder)

    let (data, response): (Data, URLResponse)
    do {
      (data, response) = try await network.data(for: request)
    } catch {
      throw HelixError.networkError(wrapped: error)
    }

    // since we are always using an http(s) url, we can force cast the response
    // swiftlint:disable:next force_cast
    let httpResponse = response as! HTTPURLResponse
    try Self.validate(data: data, response: httpResponse, decoder: decoder)

    return data
  }

  internal static func validate(
    data: Data,
    response: HTTPURLResponse,
    decoder: JSONDecoder
  ) throws {
    let statusCode = response.statusCode

    guard (200..<300) ~= statusCode else {
      let errorResponse = try? decoder.decode(HelixErrorResponse.self, from: data)

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
    -> HelixResponse<R>
  {
    let decoded = try? decoder.decode(HelixResponsePayload<R>.self, from: data)

    guard let decoded else {
      throw HelixError.parsingResponseFailed(responseData: data)
    }

    return HelixResponse(payload: decoded, rawData: data)
  }
}
