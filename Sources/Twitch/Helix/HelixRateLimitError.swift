import Foundation

/// Details of an HTTP 429 (Too Many Requests) response from Twitch Helix.
///
/// Carried by ``HelixError/rateLimited(_:)`` whenever Twitch responds with HTTP 429,
/// even if the error body is empty or non-JSON.
///
/// - Note: Some Helix endpoints enforce endpoint-specific cooldowns separate from the
///   general token bucket, so `metadata.rateLimit?.resetAt` is not guaranteed to be a
///   universal retry timestamp. See <doc:RateLimiting>.
public struct HelixRateLimitError: Error, Sendable {
  /// The HTTP status (429) and any valid rate-limit headers from the rejected response.
  public let metadata: HelixResponseMetadata
  /// Twitch's short error name, when the response body decoded as a Twitch error payload.
  public let name: String?
  /// Twitch's explanatory error message, when the response body decoded as a Twitch error.
  public let message: String?
  /// The unmodified HTTP response body bytes, including empty or non-JSON responses.
  public let responseData: Data
}
