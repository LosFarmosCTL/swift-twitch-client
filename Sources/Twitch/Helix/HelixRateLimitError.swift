import Foundation

/// Details of an HTTP 429 (Too Many Requests) response from Twitch Helix.
///
/// Carried by ``HelixError/rateLimited(_:)`` whenever Twitch responds with HTTP 429,
/// even if the error body is empty or non-JSON.
///
/// - Note: Some Helix endpoints enforce endpoint-specific cooldowns separate from the
///   general token bucket, so `metadata.rateLimit?.resetAt` is not guaranteed to be a
///   universal retry timestamp. See <doc:RateLimiting>.
public struct HelixRateLimitError: Error, Sendable, Equatable {
  /// The HTTP status (429) and any valid rate-limit headers from the rejected response.
  public let metadata: HelixResponseMetadata
  /// Twitch's short error name, when the response body decoded as a Twitch error payload.
  public let name: String?
  /// Twitch's explanatory error message, when the response body decoded as a Twitch error.
  public let message: String?
  /// The unmodified HTTP response body bytes, including empty or non-JSON responses.
  public let responseData: Data

  /// Creates a `HelixRateLimitError` value.
  public init(
    metadata: HelixResponseMetadata,
    name: String? = nil,
    message: String? = nil,
    responseData: Data = Data()
  ) {
    self.metadata = metadata
    self.name = name
    self.message = message
    self.responseData = responseData
  }
}

extension HelixRateLimitError: CustomStringConvertible {
  /// A diagnostic description of the rate-limit error.
  public var description: String {
    "Rate Limited: \(message ?? "Too Many Requests")"
  }
}

#if !os(Linux)
  extension HelixRateLimitError: CustomLocalizedStringResourceConvertible {
    /// The localized string resource describing this error.
    public var localizedStringResource: LocalizedStringResource {
      .init("Rate Limited: \(message ?? "Too Many Requests")", bundle: .twitchModule)
    }
  }
#endif

extension HelixRateLimitError: LocalizedError {
  /// A localized description suitable for presenting this error.
  public var errorDescription: String? {
    #if !os(Linux)
      return String(localized: self.localizedStringResource)
    #else
      return self.description
    #endif
  }
}
