public enum HelixError: Error {
  case missingClientID
  case invalidResponse(rawResponse: String)
  case invalidErrorResponse(status: Int, rawResponse: String)
}

internal struct TwitchError: Error, Decodable {
  let error: String
  let status: Int
  let message: String
}
