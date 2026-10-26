/// A property wrapper that decodes incompatible or null values as `nil`.
@propertyWrapper public struct NilOnTypeMismatch<Value: Sendable>: Sendable {
  /// The decoded value, or `nil` when the payload has a mismatched type.
  public var wrappedValue: Value?
  /// Wraps an optional initial value.
  ///
  /// - Parameters:
  ///   - wrappedValue: The initial value to wrap.
  public init(wrappedValue: Value?) {
    self.wrappedValue = wrappedValue
  }
}

extension NilOnTypeMismatch: Decodable where Value: Decodable {
  /// Decodes a value, replacing an incompatible or null payload with `nil`.
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.wrappedValue = try? container.decode(Value.self)
  }
}
