import Foundation

#if os(Linux)
  extension Date {
    func formatted(_ format: DateStyle) -> String {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
      return formatter.string(from: self)
    }
  }

  @frozen public enum DateStyle { case iso8601 }
#endif
