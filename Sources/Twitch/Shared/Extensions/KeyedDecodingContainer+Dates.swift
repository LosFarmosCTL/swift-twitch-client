import Foundation

extension KeyedDecodingContainer {
  /// Twitch uses zero Unix seconds to indicate that an ad timestamp is unavailable.
  internal func decodeAdDate(forKey key: Key) throws -> Date? {
    let seconds = try decode(Int64.self, forKey: key)
    return seconds == 0 ? nil : Date(timeIntervalSince1970: TimeInterval(seconds))
  }
}
