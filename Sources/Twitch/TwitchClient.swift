import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public actor TwitchClient {
  internal var authentication: TwitchCredentials
  internal let network: NetworkSession

  internal let encoder: JSONEncoder
  internal let decoder: JSONDecoder

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

    self.encoder = Self.makeEncoder()
    self.decoder = Self.makeDecoder()

    self.eventSubClient = EventSubClient(
      credentials: authentication,
      network: network,
      decoder: self.decoder)
  }

  public func switchCredentials(to credentials: TwitchCredentials) async {
    await eventSubClient.switchCredentials(to: credentials)
    authentication = credentials
  }

  internal static func makeEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601withFractionalSeconds
    encoder.keyEncodingStrategy = .convertToSnakeCase

    return encoder
  }

  internal static func makeDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601withFractionalSeconds
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    return decoder
  }

}
