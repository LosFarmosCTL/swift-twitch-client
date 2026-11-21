import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Rate-limit headers observed on a single Helix HTTP response.
///
/// Twitch reports bucket capacity, remaining points, and reset timestamp via the
/// `Ratelimit-Limit`, `Ratelimit-Remaining`, and `Ratelimit-Reset` headers. Each field
/// is parsed independently; missing, negative, or malformed header values remain `nil`
/// without failing an otherwise successful request.
///
/// - Note: Values represent a single server observation and may arrive out of order for
///   concurrent requests. The library never sleeps, queues, or retries automatically based
///   on these values.
/// - SeeAlso: <doc:RateLimiting>, ``HelixResponseMetadata``, ``HelixRateLimitError``
public struct HelixRateLimit: Sendable, Equatable, Hashable {
  /// The total point capacity of the rate-limit bucket (`Ratelimit-Limit`), if present.
  public let limit: Int?
  /// The remaining points in the bucket after this request (`Ratelimit-Remaining`), if present.
  public let remaining: Int?
  /// When the bucket resets (`Ratelimit-Reset`), interpreted directly from Twitch's Unix
  /// timestamp without local clock skew adjustment.
  public let resetAt: Date?
  /// The local wall-clock time when this response was processed.
  public let observedAt: Date

  /// Creates a `HelixRateLimit` value.
  public init(
    limit: Int? = nil,
    remaining: Int? = nil,
    resetAt: Date? = nil,
    observedAt: Date = Date()
  ) {
    self.limit = limit
    self.remaining = remaining
    self.resetAt = resetAt
    self.observedAt = observedAt
  }

  internal init?(response: HTTPURLResponse, observedAt: Date) {
    let limit = Self.points(response, field: "Ratelimit-Limit")
    let remaining = Self.points(response, field: "Ratelimit-Remaining")

    let timestamp = response.value(forHTTPHeaderField: "Ratelimit-Reset")
      .flatMap { Int64($0.trimmingCharacters(in: .whitespacesAndNewlines)) }

    let resetAt = timestamp.flatMap { value -> Date? in
      guard value >= 0,
        Double(value) <= Date.distantFuture.timeIntervalSince1970
      else { return nil }
      return Date(timeIntervalSince1970: Double(value))
    }

    guard limit != nil || remaining != nil || resetAt != nil else { return nil }
    self.limit = limit
    self.remaining = remaining
    self.resetAt = resetAt
    self.observedAt = observedAt
  }

  private static func points(_ response: HTTPURLResponse, field: String) -> Int? {
    guard let raw = response.value(forHTTPHeaderField: field),
      let value = Int(raw.trimmingCharacters(in: .whitespacesAndNewlines)),
      value >= 0
    else { return nil }

    return value
  }
}
