import Foundation

extension JSONDecoder.DateDecodingStrategy {
  static let iso8601withFractionalSeconds = custom { decoder in
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)

    let fractionalStyle = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
    if let date = try? Date(string, strategy: fractionalStyle) { return date }

    // fallback: no fractional seconds
    if let date = try? Date(string, strategy: .iso8601) { return date }

    throw DecodingError.dataCorruptedError(
      in: container,
      debugDescription: "Invalid date: \(string)")
  }
}

extension JSONEncoder.DateEncodingStrategy {
  static let iso8601withFractionalSeconds = custom { (date: Date, encoder: Encoder) in
    var container = encoder.singleValueContainer()
    let fractionalStyle = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
    try container.encode(date.formatted(fractionalStyle))
  }
}
