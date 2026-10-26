import Foundation

#if os(Linux)
  extension Date {
    func formatted(_ format: DateStyle) -> String {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
      return formatter.string(from: self)
    }
  }

  /// Date formats supported by the library’s Linux formatting helper.
  @frozen public enum DateStyle {
    /// Formats a date using an ISO 8601 timestamp.
    case iso8601
  }
#endif
