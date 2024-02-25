public struct HelixResponse<T: Decodable>: Decodable {
  let data: [T]

  let pagination: Pagination?
  let total: Int?
  let points: Int?
  let template: String?

  internal struct Pagination: Decodable { let cursor: String? }
}

internal struct HelixErrorResponse: Decodable {
  let error: String
  let status: Int
  let message: String
}
