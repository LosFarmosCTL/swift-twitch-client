import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public actor TwitchClient {
  internal let authentication: TwitchCredentials
  internal let urlSession: URLSession

  internal let encoder = JSONEncoder()
  internal let decoder = JSONDecoder()

  internal var eventSubHandlers = [any EventSubHandler]()

  internal var eventSubClient: EventSubClient

  public init(
    authentication: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default)
  ) {
    self.authentication = authentication
    self.urlSession = urlSession

    self.encoder.dateEncodingStrategy = .iso8601withFractionalSeconds
    self.decoder.dateDecodingStrategy = .iso8601withFractionalSeconds

    self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    self.encoder.keyEncodingStrategy = .convertToSnakeCase

    self.eventSubClient = EventSubClient(
      credentials: authentication, urlSession: urlSession, decoder: self.decoder)
  }
}
