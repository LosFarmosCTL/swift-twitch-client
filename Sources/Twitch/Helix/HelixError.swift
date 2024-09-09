import Foundation

public enum HelixError: Error {
  case networkError(wrapped: Error)
  case twitchError(name: String, status: Int, message: String)

  case parsingResponseFailed(responseData: Data)
  case parsingErrorFailed(status: Int, responseData: Data)

  case noDataInResponse
  case missingDataInResponse

  case nonEmptyResponse(responseData: Data)
}
