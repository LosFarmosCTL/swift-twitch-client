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
