internal struct HelixData<T>: Decodable where T: Decodable { let data: [T] }
