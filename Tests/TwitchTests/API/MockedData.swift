import Foundation

public final class MockedData {}

extension URL {
  // swiftlint:disable force_try
  var data: Data {
    return try! Data(contentsOf: self)
  }
}
