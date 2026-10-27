import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// An endpoint's result together with metadata from the same HTTP response.
public struct HelixResponse<Value> {
  /// The value produced by the endpoint, or `()` for an empty-body endpoint.
  public let value: Value
  /// The HTTP status and rate-limit headers for this response.
  public let metadata: HelixResponseMetadata
}

extension HelixResponse: Sendable where Value: Sendable {}

/// Metadata reported by one Helix HTTP response, without local capacity estimates.
public struct HelixResponseMetadata: Sendable, Equatable {
  /// The HTTP response status code.
  public let statusCode: Int
  /// The valid rate-limit header fields, or `nil` when none are available.
  public let rateLimit: HelixRateLimit?

  internal init(response: HTTPURLResponse) {
    self.statusCode = response.statusCode
    self.rateLimit = HelixRateLimit(response: response, observedAt: Date())
  }
}
