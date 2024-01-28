internal struct HelixData<T>: Decodable where T: Decodable {
  let data: [T]
  let pagination: Pagination?
  let total: Int?

  enum CodingKeys: String, CodingKey {
    case data
    case pagination
    case total
  }

  internal struct Pagination: Decodable { let cursor: String? }
}
