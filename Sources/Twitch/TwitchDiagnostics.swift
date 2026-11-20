import Foundation

/// Opt-in decoding diagnostics for Helix responses and skipped EventSub messages.
public struct TwitchDiagnostics: Sendable {
  private let onDecodingFailure: (@Sendable (TwitchDecodingDiagnostic) -> Void)?
  private let streams: DecodingDiagnosticStreams?

  /// Creates diagnostics configuration. The default installs no callback.
  ///
  /// The handler runs synchronously where a failure is handled, with no main-actor
  /// guarantee. Requests and connections may call it concurrently, so keep it brief
  /// and synchronize any mutable state it uses.
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

/// Structured information about a decoding failure.
public struct TwitchDecodingFailureDetails: Sendable, Equatable {
  public enum Kind: String, Sendable {
    case keyNotFound, typeMismatch, valueNotFound, dataCorrupted, other
  }

  public enum PathComponent: Sendable, Equatable {
    case key(String)
    case index(Int)
  }

  public let kind: Kind
  /// Decoder keys and array indices, including the missing key for `keyNotFound`.
  /// Key decoding strategies can make these differ from the wire keys.
  public let codingPath: [PathComponent]
  /// The Swift type name for a type mismatch or missing value, when available.
  public let expectedType: String?

  /// A readable path such as `data[0].broadcasterType`, or `$` at the root.
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

/// A diagnostic with no payload body or original error. Delivery does not end an EventSub stream.
public struct TwitchDecodingDiagnostic: Sendable, Equatable {
  public enum Source: Sendable {
    case helix, eventSub
  }

  public enum Stage: Sendable {
    case response, errorResponse, pagination, eventSubMessage, eventSubPayload
  }

  /// EventSub context available when the failure was reported.
  public struct EventSubMetadata: Sendable, Equatable {
    /// The local identifier of the WebSocket connection that received the frame.
    public let connectionID: UUID
    /// The identifier of the EventSub message envelope.
    public let messageID: String?
    /// The wire message type, such as `notification` or `session_welcome`.
    public let messageType: String?
    /// When Twitch sent the message, if available.
    public let sentAt: Date?
    /// The Twitch subscription identifier.
    public let subscriptionID: String?
    public let subscriptionType: String?
    public let subscriptionVersion: String?
    /// The broadcaster ID when the registered subscription identifies one channel.
    public let channelID: String?
  }

  public let source: Source
  public let stage: Stage
  public let details: TwitchDecodingFailureDetails
  public let payloadByteCount: Int
  /// Status and rate-limit information for a Helix response.
  public let metadata: HelixResponseMetadata?
  public let requestMethod: String?
  /// The Helix endpoint path without query parameters.
  public let requestPath: String?
  /// The connection and any available message and subscription metadata for EventSub.
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
