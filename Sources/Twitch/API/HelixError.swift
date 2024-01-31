public enum HelixError: Error {
  case missingClientID
  case missingUserID
  case invalidResponse(rawResponse: String)
  case invalidErrorResponse(status: Int, rawResponse: String)

  case requestFailed(error: String, status: Int, message: String)
}

internal struct TwitchError: Error, Decodable {
  let error: String
  let status: Int
  let message: String
}
