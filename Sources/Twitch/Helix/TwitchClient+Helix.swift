import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension TwitchClient {
  public static func helix<R: Sendable, H: Sendable & Decodable>(
    endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Void>,
    credentials: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default)
  ) async throws {
    let network = URLSessionNetworkSession(session: urlSession)
    let data = try await Self.data(
      for: endpoint,
      credentials: credentials,
      network: network)

    guard data.isEmpty else {
      throw HelixError.nonEmptyResponse(responseData: data)
    }
  }

  public static func helix<R: Sendable, H: Sendable & Decodable>(
    endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Normal>,
    credentials: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default)
  ) async throws -> R {
    let network = URLSessionNetworkSession(session: urlSession)
    let data = try await Self.data(
      for: endpoint,
      credentials: credentials,
      network: network)

    let response = try Self.decode(data) as HelixResponse<H>
    return try endpoint.makeResponse(from: response)
  }

  public static func helix<R: Sendable, H: Sendable & Decodable>(
    endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Raw>,
    credentials: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default)
  ) async throws -> R {
    let network = URLSessionNetworkSession(session: urlSession)
    let data = try await Self.data(
      for: endpoint,
      credentials: credentials,
      network: network)

    return try endpoint.makeResponse(from: data)
  }

  public func helix<R, H: Sendable & Decodable>(
    endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Void>
  ) async throws {
    let data = try await self.data(for: endpoint)

    guard data.isEmpty else {
      throw HelixError.nonEmptyResponse(responseData: data)
    }
  }

  public func helix<R, H: Sendable & Decodable>(
    endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Normal>
  ) async throws -> R {
    let data = try await self.data(for: endpoint)
    let response = try Self.decode(data, decoder: self.decoder) as HelixResponse<H>

    return try endpoint.makeResponse(from: response)
  }

  public func helix<R, H: Sendable & Decodable>(
    endpoint: HelixEndpoint<R, H, HelixEndpointResponseTypes.Raw>
  ) async throws -> R {
    let data = try await self.data(for: endpoint)

    return try endpoint.makeResponse(from: data)
  }

}
