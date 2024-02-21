import Foundation

extension Formatter {
  static let iso8601withFractionalSeconds: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }()
  static let iso8601: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter
  }()
}

extension JSONDecoder.DateDecodingStrategy {
  static let iso8601withFractionalSeconds = custom {
    let container = try $0.singleValueContainer()
    let string = try container.decode(String.self)
    if let date = Formatter.iso8601withFractionalSeconds.date(from: string)
      ?? Formatter.iso8601.date(from: string)
    {
      return date
    }
    throw DecodingError.dataCorruptedError(
      in: container, debugDescription: "Invalid date: \(string)")
  }
}

extension JSONEncoder.DateEncodingStrategy {
  static let iso8601withFractionalSeconds = custom {
    var container = $1.singleValueContainer()
    try container.encode(Formatter.iso8601withFractionalSeconds.string(from: $0))
  }
}
