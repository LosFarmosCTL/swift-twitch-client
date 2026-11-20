import Foundation

/// Details of a Helix response or error-body decoding failure.
///
/// Attached to ``HelixError/parsingResponseFailed(_:)`` and
/// ``HelixError/parsingErrorFailed(status:failure:)``, `HelixDecodingFailure` pairs
/// structured ``TwitchDecodingFailureDetails`` with the original Swift error and raw
/// response bytes for local debugging.
///
/// - Important: ``underlyingError`` and ``responseData`` may contain sensitive response
///   values. Avoid logging them verbatim to shared telemetry; prefer ``details`` or
///   ``TwitchDecodingDiagnostic`` instead.
/// - SeeAlso: <doc:Diagnostics>, ``TwitchDecodingFailureDetails``
public struct HelixDecodingFailure: Sendable {
  /// Structured failure kind, coding path, and expected Swift type.
  public let details: TwitchDecodingFailureDetails
  /// The original error thrown by the decoder (typically a `DecodingError`).
  public let underlyingError: any Error
  /// The raw HTTP response body bytes returned by Twitch.
  public let responseData: Data
  /// HTTP status code and rate-limit headers from the response, when available.
  public let metadata: HelixResponseMetadata?

  /// Creates a Helix decoding failure record from a decoder error and raw response body.
  ///
  /// - Parameters:
  ///   - underlyingError: The error thrown during decoding.
  ///   - responseData: The raw HTTP response body bytes.
  ///   - metadata: Optional HTTP status and rate-limit metadata from the response.
  public init(
    underlyingError: any Error, responseData: Data,
    metadata: HelixResponseMetadata? = nil
  ) {
    self.details = TwitchDecodingFailureDetails(error: underlyingError)
    self.underlyingError = underlyingError
    self.responseData = responseData
    self.metadata = metadata
  }
}
