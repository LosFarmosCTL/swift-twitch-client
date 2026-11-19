import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// An actor that provides authenticated access to Twitch Helix and EventSub.
///
/// Create a client with ``TwitchCredentials``, then execute typed ``HelixEndpoint``
/// requests or observe ``EventSubSubscription`` events. IRC sessions created by this
/// client have independent lifetimes.
public actor TwitchClient {
  internal private(set) var credentials: TwitchCredentials
  internal let network: NetworkSession

  internal let encoder: JSONEncoder
  internal let decoder: JSONDecoder

  internal let eventSubClient: EventSubClient
  var eventSubRevision: UInt64 = 0
  var eventSubResetTask: Task<Void, Never>?

  /// Creates a client with the supplied credentials and network session.
  ///
  /// - Parameters:
  ///   - credentials: The credentials used to authorize the request.
  ///   - urlSession: The URL session used for network requests. Defaults to
  ///     `URLSession(configuration: .default)`.
  public init(
    credentials: TwitchCredentials,
    urlSession: URLSession = URLSession(configuration: .default)
  ) {
    let network = URLSessionNetworkSession(session: urlSession)

    self.init(
      credentials: credentials,
      network: network)
  }

  internal init(
    credentials: TwitchCredentials,
    network: NetworkSession
  ) {
    self.credentials = credentials
    self.network = network

    self.encoder = Self.makeEncoder()
    self.decoder = Self.makeDecoder()

    self.eventSubClient = EventSubClient(
      network: network,
      decoder: self.decoder,
      credentials: credentials)
  }

  deinit {
    let eventSubClient = eventSubClient
    Task { await eventSubClient.retire() }
  }

  /// Replaces the credentials used by this client’s Helix and EventSub operations.
  ///
  /// EventSub observers finish when teardown begins. Create new subscriptions with the
  /// new credentials. Independently created IRC sessions retain their captured credentials.
  ///
  /// - Parameters:
  ///   - credentials: The credentials used to authorize the request.
  public func switchCredentials(to credentials: TwitchCredentials) async {
    self.credentials = credentials
    await startEventSubReset().value
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
