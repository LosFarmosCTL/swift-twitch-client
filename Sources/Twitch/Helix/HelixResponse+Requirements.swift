import Foundation

extension HelixResponse {
  internal func requireFirst() throws -> T {
    guard let value = data.first else {
      throw HelixError.noDataInResponse(responseData: rawData)
    }

    return value
  }

  internal func require<Value>(
    _ keyPath: KeyPath<Self, Value?>
  ) throws -> Value {
    guard let value = self[keyPath: keyPath] else {
      throw HelixError.missingDataInResponse(responseData: rawData)
    }

    return value
  }
}
