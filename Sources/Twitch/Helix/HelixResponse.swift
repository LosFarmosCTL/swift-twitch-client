import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A Helix endpoint's decoded value paired with metadata from the HTTP response.
///
/// Every Helix request returns a `HelixResponse` so you can inspect both the payload
/// (``value``) and HTTP/rate-limit headers (``metadata``). Endpoints with an empty HTTP
/// body return `HelixResponse<Void>`, which is `@discardableResult` on ``TwitchClient``.
///
/// - SeeAlso: <doc:Helix>, <doc:RateLimiting>, ``HelixResponseMetadata``
public struct HelixResponse<Value> {
  /// The decoded endpoint result, or `()` for an empty-body endpoint.
  public let value: Value
  /// The HTTP status code and parsed rate-limit headers from this response.
  public let metadata: HelixResponseMetadata
}

extension HelixResponse: Sendable where Value: Sendable {}

/// HTTP status and rate-limit headers observed on a single Helix response.
///
/// Metadata reflects one response at the time it was processed rather than a live
/// estimate of remaining capacity.
///
/// - SeeAlso: ``HelixRateLimit``, <doc:RateLimiting>
public struct HelixResponseMetadata: Sendable, Equatable {
  /// The HTTP status code returned by Twitch.
  public let statusCode: Int
  /// Parsed rate-limit headers from this response, or `nil` when none were valid or present.
  public let rateLimit: HelixRateLimit?

  internal init(response: HTTPURLResponse) {
    self.statusCode = response.statusCode
    self.rateLimit = HelixRateLimit(response: response, observedAt: Date())
  }
}
