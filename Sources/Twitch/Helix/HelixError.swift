import Foundation

/// An HTTP, transport, or response-processing failure from a Helix request.
public enum HelixError: Error, Sendable {
  /// The credential kind or a token-dependent parameter is incompatible with the endpoint.
  case authenticationError(TwitchAuthenticationError)
  /// The operation was cancelled.
  case cancelled
  /// The network request failed; carries the underlying error.
  case networkError(wrapped: Error)
  /// The operation failed with an unexpected underlying error.
  case unexpectedError(wrapped: Error)
  /// Twitch rejected the request; carries the error name, HTTP status, and message.
  case twitchError(name: String, status: Int, message: String)

  /// The success response could not be decoded; carries the raw response body.
  case parsingResponseFailed(responseData: Data)
  /// The error response could not be decoded; carries the HTTP status and raw body.
  case parsingErrorFailed(status: Int, responseData: Data)

  /// The response contained no required data; carries the raw response body.
  case noDataInResponse(responseData: Data)
  /// The response omitted required metadata; carries the raw response body.
  case missingDataInResponse(responseData: Data)

  /// An endpoint requiring an empty response returned a body; carries that body.
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
    case .parsingResponseFailed(let responseData):
      return "Parsing Response Failed: \(responseData.debugDescription)"
    case .parsingErrorFailed(let status, let responseData):
      return "Parsing Error Failed: \(status) \(responseData.debugDescription)"
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
      case .parsingResponseFailed(let responseData):
        .init("Parsing Response Failed: \(responseData.debugDescription)")
      case .parsingErrorFailed(let status, let responseData):
        .init("Parsing Error Failed: \(status) \(responseData.debugDescription)")
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
