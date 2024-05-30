@propertyWrapper public struct NilOnTypeMismatch<Value> {
  public var wrappedValue: Value?
  public init(wrappedValue: Value?) {
    self.wrappedValue = wrappedValue
  }
}

extension NilOnTypeMismatch: Decodable where Value: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.wrappedValue = try? container.decode(Value.self)
  }
}
