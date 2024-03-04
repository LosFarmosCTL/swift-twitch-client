public enum HelixError: Error {
  case networkError(wrapped: Error)
  case twitchError(name: String, status: Int, message: String)

  case parsingResponseFailed(rawResponse: String)
  case parsingErrorFailed(status: Int, rawResponse: String)

  case noDataInResponse

  case nonEmptyResponse(rawResponse: String)
}
