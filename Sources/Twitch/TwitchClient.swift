import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public actor TwitchClient {
  internal let authentication: TwitchCredentials
  internal let urlSession: URLSession

  internal let encoder = JSONEncoder()
  internal let decoder = JSONDecoder()

  public init(
    authentication: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default)
  ) throws {
    self.authentication = authentication
    self.urlSession = urlSession

    self.encoder.dateEncodingStrategy = .iso8601withFractionalSeconds
    self.decoder.dateDecodingStrategy = .iso8601withFractionalSeconds
  }

}
