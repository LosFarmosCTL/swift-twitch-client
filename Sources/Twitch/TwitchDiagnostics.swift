import Foundation

/// Configuration for observing Helix and EventSub decoding failures via callback.
///
/// Pass a `TwitchDiagnostics` instance to ``TwitchClient/init(credentials:chat:urlSession:diagnostics:)``
/// or to static Helix methods such as
/// ``TwitchClient/helix(for:credentials:urlSession:diagnostics:)`` to receive structured
/// ``TwitchDecodingDiagnostic`` reports whenever payload decoding fails.
///
/// For async-stream observation on a ``TwitchClient`` instance, see
/// ``TwitchClient/decodingDiagnostics()``. Both mechanisms receive identical reports.
///
/// - SeeAlso: <doc:Diagnostics>, ``TwitchDecodingDiagnostic``, ``HelixDecodingFailure``
public struct TwitchDiagnostics: Sendable {
  private let onDecodingFailure: (@Sendable (TwitchDecodingDiagnostic) -> Void)?
  private let streams: DecodingDiagnosticStreams?

  /// Creates a diagnostics configuration with an optional decoding-failure callback.
  ///
  /// - Parameter onDecodingFailure: A callback invoked synchronously whenever a Helix or
  ///   EventSub decoding failure occurs, or `nil` to disable callback delivery. The
  ///   closure has no main-actor guarantee and may be called concurrently from multiple
  ///   requests or WebSocket connections, so keep it fast and synchronize shared state.
  public init(onDecodingFailure: (@Sendable (TwitchDecodingDiagnostic) -> Void)? = nil) {
    self.onDecodingFailure = onDecodingFailure
    self.streams = nil
  }

  internal init(_ configuration: TwitchDiagnostics, streams: DecodingDiagnosticStreams) {
    self.onDecodingFailure = configuration.onDecodingFailure
    self.streams = streams
  }

  internal func report(_ makeDiagnostic: @autoclosure () -> TwitchDecodingDiagnostic) {
    let observers = streams?.continuations
    guard onDecodingFailure != nil || observers?.isEmpty == false else { return }

    let diagnostic = makeDiagnostic()

    if let observers { for observer in observers { observer.yield(diagnostic) } }
    onDecodingFailure?(diagnostic)
  }
}

/// Stream registrations owned by one Twitch client.
internal final class DecodingDiagnosticStreams: @unchecked Sendable {
  typealias Continuation = AsyncStream<TwitchDecodingDiagnostic>.Continuation

  // Keep yielding and finishing outside the registration lock.
  private let lock = NSLock()
  private var observers: [UUID: Continuation] = [:]

  var continuations: [UUID: Continuation].Values {
    lock.withLock { observers.values }
  }

  func stream() -> AsyncStream<TwitchDecodingDiagnostic> {
    let id = UUID()
    let (stream, continuation) = AsyncStream<TwitchDecodingDiagnostic>.makeStream(
      bufferingPolicy: .bufferingNewest(64))
    continuation.onTermination = { [weak self] _ in self?.removeObserver(id) }
    lock.withLock { observers[id] = continuation }
    return stream
  }

  func finish() {
    let continuations = lock.withLock {
      defer { observers.removeAll() }
      return observers.values
    }
    for continuation in continuations { continuation.finish() }
  }

  private func removeObserver(_ id: UUID) {
    lock.withLock { observers[id] = nil }
  }
}

/// Structured summary of a Swift `DecodingError` or other decoding failure.
///
/// `TwitchDecodingFailureDetails` extracts the failure category, coding path, and expected
/// Swift type without retaining raw payload bodies or arbitrary error strings.
///
/// - SeeAlso: ``TwitchDecodingDiagnostic``, ``HelixDecodingFailure``, <doc:Diagnostics>
public struct TwitchDecodingFailureDetails: Sendable, Equatable {
  /// The category of decoding failure extracted from `DecodingError`.
  public enum Kind: String, Sendable {
    /// A required key was missing from the decoded container (`DecodingError.keyNotFound`).
    case keyNotFound
    /// A decoded value had an unexpected type (`DecodingError.typeMismatch`).
    case typeMismatch
    /// A non-optional value was `null` (`DecodingError.valueNotFound`).
    case valueNotFound
    /// The input data was malformed or failed custom validation (`DecodingError.dataCorrupted`).
    case dataCorrupted
    /// The failure was not a standard Swift `DecodingError`.
    case other
  }

  /// One segment along a decoder's coding path.
  public enum PathComponent: Sendable, Equatable {
    /// A keyed container property name (as seen by the decoder).
    case key(String)
    /// A zero-based index into an unkeyed array container.
    case index(Int)
  }

  /// The category of decoding failure.
  public let kind: Kind
  /// The sequence of decoder keys and array indices leading to the failure.
  ///
  /// For ``Kind/keyNotFound``, the missing key is appended as the final component.
  /// Because the client's JSON decoder uses `convertFromSnakeCase`, key names may use
  /// camelCase rather than Twitch's original snake_case wire spelling.
  public let codingPath: [PathComponent]
  /// The expected Swift type name for ``Kind/typeMismatch`` or ``Kind/valueNotFound``,
  /// or `nil` for other kinds.
  public let expectedType: String?

  /// A formatted dot-and-bracket path such as `data[0].broadcasterType`, or `$` at the root.
  public var pathDescription: String {
    let path = codingPath.reduce(into: "") { path, component in
      switch component {
      case .key(let key): path += path.isEmpty ? key : ".\(key)"
      case .index(let index): path += "[\(index)]"
      }
    }
    return path.isEmpty ? "$" : path
  }

  internal init(error: any Error) {
    let path: [any CodingKey]
    switch error {
    case DecodingError.keyNotFound(let key, let context):
      kind = .keyNotFound
      path = context.codingPath + [key]
      expectedType = nil
    case DecodingError.typeMismatch(let type, let context):
      kind = .typeMismatch
      path = context.codingPath
      expectedType = String(describing: type)
    case DecodingError.valueNotFound(let type, let context):
      kind = .valueNotFound
      path = context.codingPath
      expectedType = String(describing: type)
    case DecodingError.dataCorrupted(let context):
      kind = .dataCorrupted
      path = context.codingPath
      expectedType = nil
    default:
      kind = .other
      path = []
      expectedType = nil
    }
    codingPath = path.map { key in
      if let index = key.intValue { return .index(index) }
      return .key(key.stringValue)
    }
  }
}

/// A structured report describing a Helix or EventSub decoding failure.
///
/// Reports omit raw payload bodies and original Swift error objects to avoid leaking
/// arbitrary response contents into logs. Note that ``details`` coding paths and
/// ``eventSubMetadata`` identifiers can still reference channel or subscription metadata.
///
/// Emitting a diagnostic never terminates an active EventSub stream—malformed EventSub
/// frames are skipped so the session remains usable.
///
/// - SeeAlso: ``TwitchClient/decodingDiagnostics()``, ``TwitchDiagnostics``,
///   <doc:Diagnostics>
public struct TwitchDecodingDiagnostic: Sendable, Equatable {
  /// The Twitch subsystem that encountered the decoding failure.
  public enum Source: Sendable {
    /// A Helix HTTP request (including internal requests made by EventSub or managed chat).
    case helix
    /// An EventSub WebSocket connection.
    case eventSub
  }

  /// The decoding step where the failure occurred.
  public enum Stage: Sendable {
    /// Decoding a successful Helix response payload.
    case response
    /// Decoding a non-2xx Helix error body.
    case errorResponse
    /// Decoding an optional Helix `pagination` object; the response data remained usable
    /// without a cursor.
    case pagination
    /// Decoding an EventSub WebSocket envelope frame; the frame was skipped.
    case eventSubMessage
    /// Decoding the typed event payload of an EventSub notification; the frame was skipped.
    case eventSubPayload
  }

  /// Context captured from an EventSub WebSocket frame when decoding failed.
  public struct EventSubMetadata: Sendable, Equatable {
    /// The local identifier of the WebSocket connection that received the frame.
    public let connectionID: UUID
    /// The EventSub message envelope ID, if decoded before the failure.
    public let messageID: String?
    /// The EventSub wire message type (such as `notification` or `session_welcome`),
    /// if decoded before the failure.
    public let messageType: String?
    /// The timestamp Twitch recorded when sending the message, if available.
    public let sentAt: Date?
    /// The Twitch subscription ID, if available.
    public let subscriptionID: String?
    /// The Twitch EventSub subscription type (for example, `channel.chat.message`),
    /// if available.
    public let subscriptionType: String?
    /// The EventSub subscription schema version (for example, `"1"`), if available.
    public let subscriptionVersion: String?
    /// The broadcaster ID when the registered subscription targets a single channel.
    public let channelID: String?
  }

  /// The subsystem that reported the failure.
  public let source: Source
  /// The specific decoding stage that failed.
  public let stage: Stage
  /// Structured failure kind, coding path, and expected Swift type.
  public let details: TwitchDecodingFailureDetails
  /// The size of the raw HTTP response body or WebSocket frame, in bytes.
  public let payloadByteCount: Int
  /// HTTP status code and rate-limit headers for a Helix failure, or `nil` for EventSub.
  public let metadata: HelixResponseMetadata?
  /// The HTTP method (such as `GET` or `POST`) for a Helix failure, or `nil` for EventSub.
  public let requestMethod: String?
  /// The Helix endpoint path without query parameters, or `nil` for EventSub.
  public let requestPath: String?
  /// Connection, message, and subscription metadata for an EventSub failure, or `nil` for Helix.
  public let eventSubMetadata: EventSubMetadata?

  internal init(
    source: Source, stage: Stage, details: TwitchDecodingFailureDetails, payloadByteCount: Int,
    metadata: HelixResponseMetadata? = nil, requestMethod: String? = nil,
    requestPath: String? = nil, eventSubMetadata: EventSubMetadata? = nil
  ) {
    self.source = source
    self.stage = stage
    self.details = details
    self.payloadByteCount = payloadByteCount
    self.metadata = metadata
    self.requestMethod = requestMethod
    self.requestPath = requestPath
    self.eventSubMetadata = eventSubMetadata
  }
}
