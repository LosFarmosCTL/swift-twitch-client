internal struct HelixData<T>: Decodable where T: Decodable {
  let data: [T]
  let pagination: Pagination?
  let total: Int?
  let points: Int?
  let template: String?

  enum CodingKeys: String, CodingKey {
    case data
    case pagination
    case total
    case points
    case template
  }

  internal struct Pagination: Decodable { let cursor: String? }
}
