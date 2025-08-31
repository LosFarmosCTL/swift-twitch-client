import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public actor TwitchClient {
  internal let authentication: TwitchCredentials
  internal let network: NetworkSession

  internal let encoder = JSONEncoder()
  internal let decoder = JSONDecoder()

  internal var eventSubClient: EventSubClient

  public init(
    authentication: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default)
  ) {
    let network = URLSessionNetworkSession(session: urlSession)

    self.init(
      authentication: authentication,
      network: network)
  }

  internal init(
    authentication: TwitchCredentials,
    network: NetworkSession
  ) {
    self.authentication = authentication
    self.network = network

    self.encoder.dateEncodingStrategy = .iso8601withFractionalSeconds
    self.decoder.dateDecodingStrategy = .iso8601withFractionalSeconds

    self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    self.encoder.keyEncodingStrategy = .convertToSnakeCase

    self.eventSubClient = EventSubClient(
      credentials: authentication,
      network: network,
      decoder: self.decoder)
  }
}
