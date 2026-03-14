import Foundation

public enum HelixError: Error, Sendable {
  case networkError(wrapped: Error)
  case twitchError(name: String, status: Int, message: String)

  case parsingResponseFailed(responseData: Data)
  case parsingErrorFailed(status: Int, responseData: Data)

  case noDataInResponse(responseData: Data)
  case missingDataInResponse(responseData: Data)

  case nonEmptyResponse(responseData: Data)
}

extension HelixError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .networkError(let error):
      return "Network Error: \(error.localizedDescription)"
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
    public var localizedStringResource: LocalizedStringResource {
      let bundle = LocalizedStringResource.BundleDescription.atURL(
        Bundle.module.bundleURL)

      return switch self {
      case .networkError(let error):
        .init("Network Error: \(error.localizedDescription)", bundle: bundle)
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
  public var errorDescription: String? {
    #if !os(Linux)
      return String(localized: self.localizedStringResource)
    #else
      return self.description
    #endif
  }
}
