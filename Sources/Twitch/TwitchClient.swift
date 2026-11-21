import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// An actor that coordinates Twitch Helix requests, EventSub subscriptions, and chat.
///
/// Create a `TwitchClient` with ``TwitchCredentials`` to execute typed ``HelixEndpoint``
/// requests, observe live ``EventSubSubscription`` notifications, and participate in chat
/// through managed transports or raw IRC.
///
/// The client owns the shared `URLSession`-backed network layer, EventSub WebSocket pool,
/// and managed chat state. Because `TwitchClient` is an actor, concurrent callers can
/// safely share a single instance across tasks.
///
/// - SeeAlso: <doc:Authentication>, <doc:Helix>, <doc:EventSub>, <doc:ManagedChat>,
///   <doc:Diagnostics>
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

  /// Creates a client with the supplied credentials, chat configuration, and session.
  ///
  /// Initialization does not open any network connections. EventSub and managed chat
  /// transports connect lazily when you start observing events, joining channels, or
  /// sending IRC messages.
  ///
  /// - Parameters:
  ///   - credentials: The credentials used to authorize Helix requests, EventSub
  ///     subscriptions, and account-bound chat transports.
  ///   - chat: The fixed reader, writer, pacing, and optional moderation settings for
  ///     managed chat. Defaults to authenticated IRC reading and Helix writing.
  ///   - urlSession: The URL session used for HTTP and WebSocket traffic. Defaults to
  ///     `URLSession.shared`.
  ///   - diagnostics: Opt-in callback configuration for Helix and EventSub decoding
  ///     failures. See <doc:Diagnostics>.
  public init(
    credentials: TwitchCredentials,
    chat: ChatConfiguration = .init(),
    urlSession: URLSession = .shared,
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

  /// Observes Helix and EventSub decoding failures reported by this client.
  ///
  /// Register before starting the requests or subscriptions you want to monitor. Each
  /// call creates an independent stream that buffers up to 64 newest pending reports,
  /// dropping the oldest when full. Reports from concurrent requests or WebSocket
  /// connections may arrive in any order.
  ///
  /// Cancel the consuming task to stop observing; simply breaking out of a `for await`
  /// loop while keeping a reference to the stream leaves the registration active.
  /// Streams survive ``switchCredentials(to:chatBehavior:)`` and ``resetEventSub()``,
  /// and finish when the client is deallocated.
  ///
  /// - Returns: An async stream of structured ``TwitchDecodingDiagnostic`` reports.
  /// - SeeAlso: ``TwitchDiagnostics``, <doc:Diagnostics>
  public func decodingDiagnostics() -> AsyncStream<TwitchDecodingDiagnostic> {
    diagnosticStreams.stream()
  }

  /// Replaces the client's credentials and reconciles active transports.
  ///
  /// Subsequent Helix requests use the new credentials while in-flight requests finish
  /// with the credentials they started with. Active EventSub sessions are torn down and
  /// their observers finish; upstream subscription cleanup uses the credentials that
  /// created each subscription.
  ///
  /// Managed chat follows `chatBehavior`:
  /// - ``ChatCredentialSwitchBehavior/preserveChannels`` keeps desired channels, leaves
  ///   an anonymous IRC reader connected, and restarts account-bound transports with the
  ///   new credentials.
  /// - ``ChatCredentialSwitchBehavior/partChannels`` parts all managed channels and
  ///   ends pending readiness waits.
  ///
  /// - Parameters:
  ///   - credentials: The replacement credentials to install on this client.
  ///   - chatBehavior: How managed chat membership should respond to the credential
  ///     switch. Defaults to ``ChatCredentialSwitchBehavior/preserveChannels``.
  /// - SeeAlso: <doc:Authentication>, ``resetEventSub()``
  public func switchCredentials(
    to credentials: TwitchCredentials,
    chatBehavior: ChatCredentialSwitchBehavior = .preserveChannels
  ) async {
    self.credentials = credentials
    let reset = startEventSubReset()
    let closingChatTransports = chat.switchCredentials(to: credentials, behavior: chatBehavior)
    await reset.value
    for task in closingChatTransports {
      await task.value
    }
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
