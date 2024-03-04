internal struct HelixResponse<T: Decodable>: Decodable {
  let data: [T]

  let pagination: Pagination?
  let total: Int?
  let points: Int?
  let template: String?

  let cost: Int?
  let totalCost: Int?
  let maxTotalCost: Int?

  enum CodingKeys: String, CodingKey {
    case data
    case pagination
    case total
    case points
    case template
    case cost
    case totalCost = "total_cost"
    case maxTotalCost = "max_total_cost"
  }

  internal struct Pagination: Decodable { let cursor: String? }
}

internal struct HelixErrorResponse: Decodable {
  let error: String
  let status: Int
  let message: String
}

public struct EmptyResponse: Decodable {}
