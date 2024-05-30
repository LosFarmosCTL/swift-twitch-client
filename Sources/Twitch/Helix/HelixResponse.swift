// TODO: include raw data in response for better errors
internal struct HelixResponse<T: Decodable>: Decodable {
  let data: [T]

  let pagination: Pagination?
  let points: Int?
  let template: String?
  let total: Int?
  let totalCost: Int?
  let maxTotalCost: Int?

  internal struct Pagination: Decodable { let cursor: String? }
}

internal struct HelixErrorResponse: Decodable {
  let error: String
  let status: Int
  let message: String
}

public struct EmptyResponse: Decodable {}
