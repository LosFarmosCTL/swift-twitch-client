internal struct HelixData<T>: Decodable where T: Decodable {
  let data: [T]
  let pagination: Pagination?
}

internal struct Pagination: Decodable { let cursor: String }
