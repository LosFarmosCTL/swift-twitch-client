import Foundation

/// An error thrown or delivered when a Twitch Helix request fails.
///
/// Async Helix methods throw `HelixError` for authentication, transport, HTTP, and
/// decoding failures, and throw Swift's `CancellationError` on task cancellation.
/// Callback-based methods (``TwitchClient/helixTask(for:completionHandler:)``) map task
/// cancellation to ``cancelled``.
///
/// - SeeAlso: <doc:Helix>, <doc:RateLimiting>, <doc:Diagnostics>, ``HelixRateLimitError``,
///   ``HelixDecodingFailure``
public enum HelixError: Error, Sendable {
  /// Pre-flight credential or token-dependent parameter validation failed locally.
  case authenticationError(TwitchAuthenticationError)
  /// The request was cancelled (delivered by callback-based Helix methods).
  case cancelled
  /// The underlying network transport failed before a valid HTTP response was received.
  ///
  /// - Parameter wrapped: The transport error thrown by `URLSession` or the network layer.
  case networkError(wrapped: Error)
  /// An unexpected error occurred outside normal Helix transport or response handling.
  ///
  /// - Parameter wrapped: The underlying error.
  case unexpectedError(wrapped: Error)
  /// Twitch returned a non-2xx HTTP response whose error JSON was decoded successfully.
  ///
  /// - Parameters:
  ///   - name: The short error name reported by Twitch (for example, `"Unauthorized"`).
  ///   - status: The HTTP status code returned by Twitch.
  ///   - message: Twitch's explanatory error message.
  case twitchError(name: String, status: Int, message: String)
  /// Twitch returned HTTP 429 (Too Many Requests).
  ///
  /// Every HTTP 429 response produces this case even if the response body is empty or
  /// cannot be decoded. See <doc:RateLimiting>.
  case rateLimited(HelixRateLimitError)

  /// A 2xx Helix response body could not be decoded into the endpoint's expected model.
  ///
  /// Also reported to ``TwitchClient/decodingDiagnostics()`` and ``TwitchDiagnostics``.
  case parsingResponseFailed(HelixDecodingFailure)
  /// A non-2xx (non-429) Helix error response body could not be decoded.
  ///
  /// - Parameters:
  ///   - status: The HTTP status code returned by Twitch.
  ///   - failure: Structured decoding details, the underlying error, and raw body bytes.
  case parsingErrorFailed(status: Int, failure: HelixDecodingFailure)

  /// A Helix endpoint expected at least one item in `data`, but Twitch returned an empty list.
  ///
  /// - Parameter responseData: The raw HTTP response body returned by Twitch.
  case noDataInResponse(responseData: Data)
  /// A Helix endpoint expected a required top-level field (such as `total` or `pagination`)
  /// that was absent from the response.
  ///
  /// - Parameter responseData: The raw HTTP response body returned by Twitch.
  case missingDataInResponse(responseData: Data)

  /// An endpoint expecting an empty HTTP body received non-empty response data.
  ///
  /// - Parameter responseData: The unexpected HTTP response body returned by Twitch.
  case nonEmptyResponse(responseData: Data)
}

extension HelixError: CustomStringConvertible {
  /// A diagnostic description of the error, including associated response details.
  public var description: String {
    switch self {
    case .authenticationError(let error):
      return error.description
    case .cancelled:
      return "Cancelled"
    case .networkError(let error):
      return "Network Error: \(error.localizedDescription)"
    case .unexpectedError(let error):
      return "Unexpected Error: \(error.localizedDescription)"
    case .twitchError(let name, let status, let message):
      return "Twitch Error: \(name) (\(status)): \(message)"
    case .rateLimited(let error):
      return "Rate Limited: \(error.message ?? "Too Many Requests")"
    case .parsingResponseFailed(let failure):
      return "Parsing Response Failed: \(failure.details.pathDescription)"
    case .parsingErrorFailed(let status, let failure):
      return "Parsing Error Failed: \(status) \(failure.details.pathDescription)"
    case .noDataInResponse(let responseData):
      return "No Data in Response: \(responseData.debugDescription)"
    case .missingDataInResponse(let responseData):
      return "Missing Data in Response: \(responseData.debugDescription)"
    case .nonEmptyResponse(let responseData):
      return "Non Empty Response: \(responseData.debugDescription)"
    }
  }
}

#if !os(Linux)
  extension HelixError: CustomLocalizedStringResourceConvertible {
    /// The localized string resource describing this error.
    public var localizedStringResource: LocalizedStringResource {
      let bundle = LocalizedStringResource.BundleDescription.atURL(
        Bundle.module.bundleURL)

      return switch self {
      case .authenticationError(let error):
        .init("Authentication Error: \(error.description)", bundle: bundle)
      case .cancelled:
        .init("Cancelled", bundle: bundle)
      case .networkError(let error):
        .init("Network Error: \(error.localizedDescription)", bundle: bundle)
      case .unexpectedError(let error):
        .init("Unexpected Error: \(error.localizedDescription)", bundle: bundle)
      case .twitchError(let name, let status, let message):
        .init("Twitch Error: \(name) (\(status)): \(message)")
      case .rateLimited(let error):
        .init("Rate Limited: \(error.message ?? "Too Many Requests")")
      case .parsingResponseFailed(let failure):
        .init("Parsing Response Failed: \(failure.details.pathDescription)")
      case .parsingErrorFailed(let status, let failure):
        .init("Parsing Error Failed: \(status) \(failure.details.pathDescription)")
      case .noDataInResponse(let responseData):
        .init("No Data in Response: \(responseData.debugDescription)")
      case .missingDataInResponse(let responseData):
        .init("Missing Data in Response: \(responseData.debugDescription)")
      case .nonEmptyResponse(let responseData):
        .init("Non Empty Response: \(responseData.debugDescription)")
      }
    }
  }
#endif

extension HelixError: LocalizedError {
  /// A localized description suitable for presenting this error.
  public var errorDescription: String? {
    #if !os(Linux)
      return String(localized: self.localizedStringResource)
    #else
      return self.description
    #endif
  }
}
