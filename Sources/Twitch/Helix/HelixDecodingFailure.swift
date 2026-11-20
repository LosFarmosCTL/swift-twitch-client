import Foundation

/// A Helix parsing failure with structured details and the original Swift error.
public struct HelixDecodingFailure: Sendable {
  public let details: TwitchDecodingFailureDetails
  /// The original error from decoding, which may contain response values.
  public let underlyingError: any Error
  /// The original response body, which may contain private information.
  public let responseData: Data
  public let metadata: HelixResponseMetadata?

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
