import Foundation

/// An HTTP 429 response from Twitch, including headers and the original error body.
public struct HelixRateLimitError: Error, Sendable {
  /// The HTTP status and any valid rate-limit headers from the rejected attempt.
  public let metadata: HelixResponseMetadata
  /// Twitch's error name, when the body can be decoded.
  public let name: String?
  /// Twitch's explanation, when the body can be decoded.
  public let message: String?
  /// The unmodified response body, including empty or non-JSON error responses.
  public let responseData: Data
}
