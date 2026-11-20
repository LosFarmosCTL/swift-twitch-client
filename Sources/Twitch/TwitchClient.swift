import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// An actor that provides access to Twitch Helix, EventSub, and managed chat.
///
/// Create a client with ``TwitchCredentials``, then execute typed ``HelixEndpoint``
/// requests, observe ``EventSubSubscription`` events, or join chat with your chosen transports.
public actor TwitchClient {
  internal private(set) var credentials: TwitchCredentials
  internal let network: NetworkSession

  internal let encoder: JSONEncoder
  internal let decoder: JSONDecoder
  internal let diagnostics: TwitchDiagnostics
  private let diagnosticStreams = DecodingDiagnosticStreams()

  internal let chat: ManagedChat
  #if canImport(Combine)
    nonisolated let ircPublishers: IRCMessagePublishers
  #endif
  internal let eventSubClient: EventSubClient
  var eventSubRevision: UInt64 = 0
  var eventSubResetTask: Task<Void, Never>?

  /// Creates a client with the supplied credentials and network session.
  ///
  /// - Parameters:
  ///   - credentials: The credentials used to authorize the request.
  ///   - chat: The fixed transports and behavior for managed chat.
  ///   - urlSession: The URL session used for network requests. Defaults to
  ///     `URLSession(configuration: .default)`.
  ///   - diagnostics: Opt-in decoding diagnostics for Helix and EventSub.
  public init(
    credentials: TwitchCredentials,
    chat: ChatConfiguration = .init(),
    urlSession: URLSession = URLSession(configuration: .default),
    diagnostics: TwitchDiagnostics = .init()
  ) {
    let network = URLSessionNetworkSession(session: urlSession)

    self.init(
      credentials: credentials,
      chat: chat,
      network: network, diagnostics: diagnostics)
  }

  internal init(
    credentials: TwitchCredentials,
    chat configuration: ChatConfiguration = .init(),
    network: NetworkSession,
    diagnostics: TwitchDiagnostics = .init()
  ) {
    let diagnostics = TwitchDiagnostics(diagnostics, streams: diagnosticStreams)
    self.credentials = credentials
    self.network = network
    self.diagnostics = diagnostics

    self.encoder = Self.makeEncoder()
    self.decoder = Self.makeDecoder()

    self.eventSubClient = EventSubClient(
      network: network,
      decoder: self.decoder,
      credentials: credentials, diagnostics: diagnostics)

    let chat = ManagedChat(
      configuration: configuration, credentials: credentials, network: network,
      diagnostics: diagnostics)
    self.chat = chat
    #if canImport(Combine)
      self.ircPublishers = chat.ircPublishers
    #endif
    chat.client = self
  }

  deinit {
    diagnosticStreams.finish()
    let eventSubClient = eventSubClient
    Task { await eventSubClient.retire() }
  }

  /// Observes new Helix and EventSub decoding failures from this client.
  ///
  /// Each call registers an independent observer before returning. It keeps the 64
  /// newest pending reports, dropping the oldest when full. Reports from concurrent
  /// requests or connections may arrive in either order.
  ///
  /// Cancel the consuming task to end observation. Breaking out of a loop can leave
  /// a retained stream registered. Streams finish when the client is released.
  /// Credential changes and EventSub resets preserve the stream and any buffered reports.
  public func decodingDiagnostics() -> AsyncStream<TwitchDecodingDiagnostic> {
    diagnosticStreams.stream()
  }

  /// Replaces credentials and applies the selected managed chat membership policy.
  ///
  /// Account-bound IRC transports restart as needed. Raw EventSub observers finish
  /// when teardown begins.
  public func switchCredentials(
    to credentials: TwitchCredentials,
    chatBehavior: ChatCredentialSwitchBehavior = .preserveChannels
  ) async {
    self.credentials = credentials
    let reset = startEventSubReset()
    chat.switchCredentials(to: credentials, behavior: chatBehavior)
    await reset.value
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
