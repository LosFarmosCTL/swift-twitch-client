/// A property wrapper that decodes incompatible or null values as `nil`.
@propertyWrapper internal struct NilOnTypeMismatch<Value: Sendable>: Sendable {
  var wrappedValue: Value?
}

extension NilOnTypeMismatch: Decodable where Value: Decodable {
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.wrappedValue = try? container.decode(Value.self)
  }
}
