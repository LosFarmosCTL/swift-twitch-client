import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A server observation, rather than a prediction of current capacity.
public struct HelixRateLimit: Sendable, Equatable {
  /// The bucket capacity reported by Twitch.
  public let limit: Int?
  /// The remaining points reported by Twitch.
  public let remaining: Int?
  /// The original server Unix timestamp, without local clock adjustment.
  public let resetAt: Date?
  /// The local time this response was processed.
  public let observedAt: Date

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
